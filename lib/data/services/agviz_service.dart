import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../db/tables.dart';

/// Export/import del formato .agviz (vedi doc architettura sez. 3).
/// Scelte deliberate:
/// - il file NON contiene il profilo: niente nome del bambino in giro
/// - le foto referenziate sono incluse (avvisare l'utente alla condivisione)
/// - gli ID originali sono preservati -> re-import = aggiornamento in place
/// - isCompleted NON viaggia: lo stato runtime riparte pulito
class AgvizService {
  AgvizService(this._db, this._docsDir);

  static const int schemaVersion = 1;

  final AppDatabase _db;
  final Directory _docsDir;

  Future<File> exportAgenda(String agendaId) async {
    final agenda = await (_db.select(_db.agendas)
          ..where((t) => t.id.equals(agendaId)))
        .getSingle();
    final items = await (_db.select(_db.agendaItems)
          ..where((t) =>
              t.agendaId.equals(agendaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final activityIds = items.map((i) => i.activityId).toSet().toList();
    final activities = activityIds.isEmpty
        ? <Activity>[]
        : await (_db.select(_db.activities)
              ..where((t) => t.id.isIn(activityIds)))
            .get();
    final photoIds = activities
        .where((a) => a.pictogramType == PictogramType.photo)
        .map((a) => a.pictogramRef)
        .toList();
    final mediaRows = photoIds.isEmpty
        ? <MediaAsset>[]
        : await (_db.select(_db.mediaAssets)
              ..where((t) => t.id.isIn(photoIds)))
            .get();

    final data = {
      'agenda': {
        'id': agenda.id,
        'title': agenda.title,
        'type': agenda.type.name,
        'scheduleHint': agenda.scheduleHint,
        'sortOrder': agenda.sortOrder,
      },
      'items': [
        for (final i in items)
          {
            'id': i.id,
            'activityId': i.activityId,
            'position': i.position,
            'timerSeconds': i.timerSeconds,
          }
      ],
      'activities': [
        for (final a in activities)
          {
            'id': a.id,
            'label': a.label,
            'pictogramType': a.pictogramType.name,
            'pictogramRef': a.pictogramRef,
            'ttsText': a.ttsText,
            'color': a.color,
          }
      ],
      'media': [
        for (final m in mediaRows)
          {
            'id': m.id,
            'mimeType': m.mimeType,
            'width': m.width,
            'height': m.height,
            'sha256': m.sha256,
          }
      ],
    };

    final archive = Archive();
    void addJson(String name, Object obj) {
      final bytes = utf8.encode(jsonEncode(obj));
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    addJson('manifest.json', {
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
    });
    addJson('data.json', data);
    for (final m in mediaRows) {
      final file = File('${_docsDir.path}/${m.filePath}');
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile('media/${m.id}.jpg', bytes.length, bytes));
      }
    }

    final zipBytes = ZipEncoder().encode(archive)!;
    var safe = agenda.title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    if (safe.isEmpty) safe = 'agenda';
    final out = File('${Directory.systemTemp.path}/$safe.agviz');
    await out.writeAsBytes(zipBytes);
    return out;
  }

  /// Importa nell'agenda del profilo di destinazione. Idempotente:
  /// stesso file importato due volte = aggiornamento, non duplicato.
  Future<String> importAgenda(File file, {required String profileId}) async {
    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());

    ArchiveFile? find(String name) {
      for (final f in archive.files) {
        if (f.name == name) return f;
      }
      return null;
    }

    Map<String, dynamic> readJson(String name) {
      final f = find(name);
      if (f == null) throw AgvizException('File non valido: manca $name');
      return jsonDecode(utf8.decode(f.content as List<int>))
          as Map<String, dynamic>;
    }

    final manifest = readJson('manifest.json');
    final version = (manifest['schemaVersion'] as num?)?.toInt() ?? 0;
    if (version > schemaVersion) {
      throw AgvizException(
          'Il file arriva da una versione più recente: aggiorna l\'app');
    }

    final data = readJson('data.json');
    final agendaMap = data['agenda'] as Map<String, dynamic>;
    final agendaId = agendaMap['id'] as String;

    await _db.transaction(() async {
      for (final raw in (data['media'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        final id = m['id'] as String;
        final entry = find('media/$id.jpg');
        final relativePath = 'media/$id.jpg';
        if (entry != null) {
          final out = File('${_docsDir.path}/$relativePath');
          await out.create(recursive: true);
          await out.writeAsBytes(entry.content as List<int>);
        }
        await _db.into(_db.mediaAssets).insertOnConflictUpdate(
              MediaAssetsCompanion.insert(
                id: id,
                filePath: relativePath,
                mimeType: m['mimeType'] as String? ?? 'image/jpeg',
                width: (m['width'] as num?)?.toInt() ?? 0,
                height: (m['height'] as num?)?.toInt() ?? 0,
                sha256: m['sha256'] as String? ?? '',
              ),
            );
      }

      for (final raw in (data['activities'] as List? ?? const [])) {
        final a = raw as Map<String, dynamic>;
        await _db.into(_db.activities).insertOnConflictUpdate(
              ActivitiesCompanion.insert(
                id: a['id'] as String,
                label: a['label'] as String,
                pictogramType:
                    PictogramType.values.byName(a['pictogramType'] as String),
                pictogramRef: a['pictogramRef'] as String,
                ttsText: Value(a['ttsText'] as String?),
                color: Value(a['color'] as String?),
              ),
            );
      }

      await _db.into(_db.agendas).insertOnConflictUpdate(
            AgendasCompanion.insert(
              id: agendaId,
              profileId: profileId,
              title: agendaMap['title'] as String,
              type: AgendaType.values.byName(agendaMap['type'] as String),
              scheduleHint: Value(agendaMap['scheduleHint'] as String?),
              sortOrder: Value((agendaMap['sortOrder'] as num?)?.toInt() ?? 0),
            ),
          );

      for (final raw in (data['items'] as List? ?? const [])) {
        final i = raw as Map<String, dynamic>;
        await _db.into(_db.agendaItems).insertOnConflictUpdate(
              AgendaItemsCompanion.insert(
                id: i['id'] as String,
                agendaId: agendaId,
                activityId: i['activityId'] as String,
                position: (i['position'] as num).toInt(),
                timerSeconds: Value((i['timerSeconds'] as num?)?.toInt()),
              ),
            );
      }
    });

    return agendaId;
  }
}

class AgvizException implements Exception {
  AgvizException(this.message);
  final String message;
  @override
  String toString() => message;
}
