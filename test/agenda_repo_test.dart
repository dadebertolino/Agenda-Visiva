import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/agenda_repo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AgendaRepo agendas;
  late ActivityRepo activities;
  late String agendaId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    agendas = AgendaRepo(db);
    activities = ActivityRepo(db);
    await db.into(db.profiles).insert(
        ProfilesCompanion.insert(id: 'p1', displayName: 'Test'));
    agendaId = await agendas.create(
        profileId: 'p1', title: 'Routine', type: AgendaType.daily);
  });

  tearDown(() => db.close());

  Future<String> addActivity(String label) => activities.create(
      label: label, type: PictogramType.builtin, pictogramRef: 'gioco');

  test('addItem assegna position progressive', () async {
    final a = await addActivity('A');
    final b = await addActivity('B');
    await agendas.addItem(agendaId: agendaId, activityId: a);
    await agendas.addItem(agendaId: agendaId, activityId: b);

    final rows = await agendas.watchItems(agendaId).first;
    expect(rows.map((r) => r.activity.label), ['A', 'B']);
    expect(rows.map((r) => r.item.position), [0, 1]);
  });

  test('reorderItems riscrive le position', () async {
    final ids = <String>[];
    for (final label in ['A', 'B', 'C']) {
      final act = await addActivity(label);
      ids.add(await agendas.addItem(agendaId: agendaId, activityId: act));
    }
    await agendas.reorderItems(agendaId, [ids[2], ids[0], ids[1]]);

    final rows = await agendas.watchItems(agendaId).first;
    expect(rows.map((r) => r.activity.label), ['C', 'A', 'B']);
  });

  test('removeItem è un tombstone, non un delete fisico', () async {
    final act = await addActivity('A');
    final itemId =
        await agendas.addItem(agendaId: agendaId, activityId: act);
    await agendas.removeItem(itemId);

    final visible = await agendas.watchItems(agendaId).first;
    expect(visible, isEmpty);

    final raw = await db.select(db.agendaItems).get();
    expect(raw.single.deletedAt, isNotNull);
    expect(raw.single.dirty, isTrue);
  });

  test('completeItem e resetCompletions', () async {
    final act = await addActivity('A');
    final itemId =
        await agendas.addItem(agendaId: agendaId, activityId: act);
    await agendas.completeItem(itemId);

    var rows = await agendas.watchItems(agendaId).first;
    expect(rows.single.item.isCompleted, isTrue);

    await agendas.resetCompletions(agendaId);
    rows = await agendas.watchItems(agendaId).first;
    expect(rows.single.item.isCompleted, isFalse);
    expect(rows.single.item.completedAt, isNull);
  });
}
