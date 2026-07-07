import 'dart:io';

import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/agenda_repo.dart';
import 'package:agenda_visiva/data/services/agviz_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('roundtrip .agviz: export da un dispositivo, import su un altro',
      () async {
    // Dispositivo A (insegnante)
    final dbA = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(dbA.close);
    final tmpA = await Directory.systemTemp.createTemp('agviz_a');
    addTearDown(() => tmpA.delete(recursive: true));

    final agendasA = AgendaRepo(dbA);
    final activitiesA = ActivityRepo(dbA);
    await dbA.into(dbA.profiles).insert(
        ProfilesCompanion.insert(id: 'teacher', displayName: 'Maestra'));
    final agendaId = await agendasA.create(
        profileId: 'teacher',
        title: 'Routine scuola',
        type: AgendaType.sequence);
    for (final (label, timer) in [('Cerchio', 300), ('Pittura', null)]) {
      final act = await activitiesA.create(
          label: label, type: PictogramType.builtin, pictogramRef: 'gioco');
      await agendasA.addItem(
          agendaId: agendaId, activityId: act, timerSeconds: timer);
    }

    final file =
        await AgvizService(dbA, tmpA).exportAgenda(agendaId);
    expect(file.existsSync(), isTrue);

    // Dispositivo B (genitore)
    final dbB = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(dbB.close);
    final tmpB = await Directory.systemTemp.createTemp('agviz_b');
    addTearDown(() => tmpB.delete(recursive: true));
    await dbB.into(dbB.profiles).insert(
        ProfilesCompanion.insert(id: 'kid', displayName: 'Sofia'));

    final serviceB = AgvizService(dbB, tmpB);
    final imported = await serviceB.importAgenda(file, profileId: 'kid');
    expect(imported, agendaId);

    final agendasB = AgendaRepo(dbB);
    final agenda = (await agendasB.watchAgenda(agendaId).first)!;
    expect(agenda.title, 'Routine scuola');
    expect(agenda.type, AgendaType.sequence);
    expect(agenda.profileId, 'kid');

    final rows = await agendasB.watchItems(agendaId).first;
    expect(rows.map((r) => r.activity.label), ['Cerchio', 'Pittura']);
    expect(rows.first.item.timerSeconds, 300);
    expect(rows.every((r) => !r.item.isCompleted), isTrue);

    // Idempotenza: re-import = aggiornamento, non duplicato
    await serviceB.importAgenda(file, profileId: 'kid');
    expect((await agendasB.watchItems(agendaId).first).length, 2);
    expect((await agendasB.watchByProfile('kid').first).length, 1);
  });
}
