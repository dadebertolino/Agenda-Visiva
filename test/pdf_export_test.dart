import 'dart:io';
import 'dart:typed_data';

import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/agenda_repo.dart';
import 'package:agenda_visiva/data/services/arasaac_api.dart';
import 'package:agenda_visiva/data/services/media_store.dart';
import 'package:agenda_visiva/data/services/pdf_export.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('il PDF si genera con card builtin (offline, senza rete)', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final tmp = await Directory.systemTemp.createTemp('pdf_test');
    addTearDown(() => tmp.delete(recursive: true));

    final agendas = AgendaRepo(db);
    final activities = ActivityRepo(db);
    await db.into(db.profiles).insert(
        ProfilesCompanion.insert(id: 'p1', displayName: 'Test'));
    final agendaId = await agendas.create(
        profileId: 'p1', title: 'Routine mattina', type: AgendaType.daily);
    for (final label in ['Colazione', 'Cerchio', 'Pittura']) {
      final act = await activities.create(
          label: label, type: PictogramType.builtin, pictogramRef: 'gioco');
      await agendas.addItem(agendaId: agendaId, activityId: act);
    }

    final agenda = (await agendas.watchAgenda(agendaId).first)!;
    final rows = await agendas.watchItems(agendaId).first;
    final service = PdfExportService(
      ArasaacApi(db),
      MediaStore(db, tmp,
          compressor: (b) async => Uint8List.fromList(b)),
    );

    final bytes = await service.buildAgendaPdf(agenda: agenda, rows: rows);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('il PDF elenco giornata si genera, con e senza orari', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final tmp = await Directory.systemTemp.createTemp('pdf_list_test');
    addTearDown(() => tmp.delete(recursive: true));

    final agendas = AgendaRepo(db);
    final activities = ActivityRepo(db);
    await db.into(db.profiles).insert(
        ProfilesCompanion.insert(id: 'p1', displayName: 'Test'));
    final agendaId = await agendas.create(
        profileId: 'p1', title: 'Giornata', type: AgendaType.daily);
    for (final label in ['Colazione', 'Cerchio']) {
      final act = await activities.create(
          label: label, type: PictogramType.builtin, pictogramRef: 'gioco');
      await agendas.addItem(agendaId: agendaId, activityId: act);
    }

    // Orari solo sulla prima: il layout deve reggere entrambi i casi.
    final rows0 = await agendas.watchItems(agendaId).first;
    await agendas.setItemTimes(rows0.first.item.id,
        startTime: '08:30', endTime: '09:00');

    final agenda = (await agendas.watchAgenda(agendaId).first)!;
    final rows = await agendas.watchItems(agendaId).first;
    final service = PdfExportService(
      ArasaacApi(db),
      MediaStore(db, tmp,
          compressor: (b) async => Uint8List.fromList(b)),
    );

    final bytes =
        await service.buildAgendaListPdf(agenda: agenda, rows: rows);

    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
