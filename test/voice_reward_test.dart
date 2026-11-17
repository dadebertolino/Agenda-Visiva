import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/agenda_repo.dart';
import 'package:agenda_visiva/data/services/agviz_service.dart';
import 'package:agenda_visiva/data/services/media_store.dart';
import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un "dispositivo": DB in memoria + cartella documenti temporanea.
class _Device {
  _Device(this.db, this.dir)
      : agendas = AgendaRepo(db),
        activities = ActivityRepo(db),
        media = MediaStore(db, dir,
            compressor: (b) async => Uint8List.fromList(b)),
        agviz = AgvizService(db, dir);

  final AppDatabase db;
  final Directory dir;
  final AgendaRepo agendas;
  final ActivityRepo activities;
  final MediaStore media;
  final AgvizService agviz;

  static Future<_Device> create(String profileId) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final dir = await Directory.systemTemp.createTemp('dev');
    await db
        .into(db.profiles)
        .insert(ProfilesCompanion.insert(id: profileId, displayName: 'X'));
    return _Device(db, dir);
  }

  Future<void> dispose() async {
    await db.close();
    await dir.delete(recursive: true);
  }

  /// Simula l'output del registratore: un file temporaneo .m4a.
  Future<MediaAsset> record(String content) async {
    final tmp = File('${dir.path}/tmp_${content.hashCode}.m4a');
    await tmp.writeAsString(content);
    return media.importAudio(tmp);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Device a;
  late _Device b;

  setUp(() async {
    a = await _Device.create('teacher');
    b = await _Device.create('kid');
  });

  tearDown(() async {
    await a.dispose();
    await b.dispose();
  });

  test('importAudio sposta il file in media/ e rimuove il temporaneo',
      () async {
    final tmp = File('${a.dir.path}/rec.m4a');
    await tmp.writeAsString('voce');
    final asset = await a.media.importAudio(tmp);

    expect(asset.mimeType, 'audio/mp4');
    expect(asset.filePath, matches(RegExp(r'^media/[0-9a-f-]+\.m4a$')));
    expect(File('${a.dir.path}/${asset.filePath}').existsSync(), isTrue);
    expect(tmp.existsSync(), isFalse);
  });

  test('una voce sostituita sparisce dal disco se non serve più', () async {
    final act = await a.activities.create(
        label: 'Bagno', type: PictogramType.builtin, pictogramRef: 'bagno');
    final first = await a.record('prima');
    await a.activities.setAudio(act, first.id);

    // Ancora in uso: non si cancella.
    await a.media.deleteAudioIfUnused(first.id);
    expect(File('${a.dir.path}/${first.filePath}').existsSync(), isTrue);

    final second = await a.record('seconda');
    await a.activities.setAudio(act, second.id);
    await a.media.deleteAudioIfUnused(first.id);
    expect(File('${a.dir.path}/${first.filePath}').existsSync(), isFalse);
    expect(File('${a.dir.path}/${second.filePath}').existsSync(), isTrue);
  });

  test('.agviz trasporta voce registrata e premio', () async {
    final agendaId = await a.agendas.create(
        profileId: 'teacher', title: 'Mattina', type: AgendaType.daily);
    final act = await a.activities.create(
        label: 'Bagno', type: PictogramType.builtin, pictogramRef: 'bagno');
    await a.agendas.addItem(agendaId: agendaId, activityId: act);
    final voice = await a.record('voce della maestra');
    await a.activities.setAudio(act, voice.id);
    final reward = await a.activities.create(
        label: 'Parco', type: PictogramType.builtin, pictogramRef: 'gioco');
    await a.agendas.setReward(agendaId, reward);
    await a.agendas.setWeekdays(agendaId, {1, 3});

    final file = await a.agviz.exportAgenda(agendaId);
    await b.agviz.importAgenda(file, profileId: 'kid');

    final agenda = (await b.agendas.watchAgenda(agendaId).first)!;
    expect(agenda.rewardActivityId, reward);
    expect(agenda.scheduleHint, contains('"weekdays":[1,3]'));
    final rewardB = (await b.activities.watchById(reward).first)!;
    expect(rewardB.label, 'Parco');

    final rowB = (await b.agendas.watchItems(agendaId).first).single;
    expect(rowB.activity.audioAssetId, voice.id);
    final fileB = await b.media.fileFor(voice.id);
    expect(await fileB!.readAsString(), 'voce della maestra');
    expect(fileB.path, endsWith('.m4a'));
  });

  test('un import senza voce non cancella la voce registrata a casa',
      () async {
    final agendaId = await a.agendas.create(
        profileId: 'teacher', title: 'Mattina', type: AgendaType.daily);
    final act = await a.activities.create(
        label: 'Bagno', type: PictogramType.builtin, pictogramRef: 'bagno');
    await a.agendas.addItem(agendaId: agendaId, activityId: act);
    final file = await a.agviz.exportAgenda(agendaId);

    await b.agviz.importAgenda(file, profileId: 'kid');
    final mamma = await b.record('voce della mamma');
    await b.activities.setAudio(act, mamma.id);

    // La maestra rimanda l'agenda aggiornata (senza voce): reimport.
    await b.agviz.importAgenda(file, profileId: 'kid');
    final row = (await b.agendas.watchItems(agendaId).first).single;
    expect(row.activity.audioAssetId, mamma.id);
  });

  test('un id media con separatori di path viene ignorato', () async {
    final archive = Archive();
    void add(String name, Object json) {
      final bytes = utf8.encode(jsonEncode(json));
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add('manifest.json', {'schemaVersion': 2});
    add('data.json', {
      'agenda': {'id': 'ag1', 'title': 'T', 'type': 'daily'},
      'items': [],
      'activities': [],
      'media': [
        {'id': '../../evil', 'ext': 'm4a'}
      ],
    });
    archive.addFile(ArchiveFile('media/../../evil.m4a', 1, [0]));
    final zip = File('${a.dir.path}/evil.agviz')
      ..writeAsBytesSync(ZipEncoder().encode(archive));

    await b.agviz.importAgenda(zip, profileId: 'kid');
    expect(await b.db.select(b.db.mediaAssets).get(), isEmpty);
    expect(File('${b.dir.parent.path}/evil.m4a').existsSync(), isFalse);
  });
}
