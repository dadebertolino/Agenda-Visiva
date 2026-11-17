import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/agenda_repo.dart';
import 'package:agenda_visiva/domain/schedule_hint.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleHint', () {
    test('legge i giorni e conserva i campi che non conosce', () {
      final hint =
          ScheduleHint.fromJsonString('{"weekdays":[1,3,9],"time":"08:00"}');
      expect(hint.weekdays, {1, 3}); // 9 non è un giorno valido
      final out = hint.withWeekdays({5}).toJsonString()!;
      expect(out, contains('"time":"08:00"'));
      expect(ScheduleHint.fromJsonString(out).weekdays, {5});
    });

    test('JSON malformato o vuoto = nessun giorno', () {
      expect(ScheduleHint.fromJsonString('{rotto').isEmpty, isTrue);
      expect(ScheduleHint.fromJsonString(null).isEmpty, isTrue);
      expect(const ScheduleHint().toJsonString(), isNull);
    });

    test('appliesTo usa DateTime.weekday', () {
      final hint = ScheduleHint.fromJsonString('{"weekdays":[1]}');
      expect(hint.appliesTo(DateTime(2026, 11, 16)), isTrue); // lunedì
      expect(hint.appliesTo(DateTime(2026, 11, 17)), isFalse); // martedì
    });
  });

  group('AgendaRepo', () {
    late AppDatabase db;
    late AgendaRepo agendas;
    late String agendaId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      agendas = AgendaRepo(db);
      await db.into(db.profiles).insert(
          ProfilesCompanion.insert(id: 'p1', displayName: 'Test'));
      agendaId = await agendas.create(
          profileId: 'p1', title: 'Routine', type: AgendaType.daily);
      final act = await ActivityRepo(db).create(
          label: 'Colazione',
          type: PictogramType.builtin,
          pictogramRef: 'gioco');
      await agendas.addItem(agendaId: agendaId, activityId: act);
    });

    tearDown(() => db.close());

    test('setWeekdays salva e svuota', () async {
      await agendas.setWeekdays(agendaId, {1, 5});
      var a = (await agendas.watchAgenda(agendaId).first)!;
      expect(ScheduleHint.fromJsonString(a.scheduleHint).weekdays, {1, 5});

      await agendas.setWeekdays(agendaId, {});
      a = (await agendas.watchAgenda(agendaId).first)!;
      expect(a.scheduleHint, isNull);
    });

    test('resetIfStale azzera solo le spunte dei giorni precedenti', () async {
      final item = (await agendas.watchItems(agendaId).first).single.item;
      final now = DateTime(2026, 11, 17, 10);

      // Spunta di oggi: resta.
      await (db.update(db.agendaItems)..where((t) => t.id.equals(item.id)))
          .write(AgendaItemsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime(2026, 11, 17, 8).toUtc()),
      ));
      expect(await agendas.resetIfStale(agendaId, now: now), isFalse);
      expect((await agendas.watchItems(agendaId).first).single.item.isCompleted,
          isTrue);

      // Spunta di ieri sera: l'agenda riparte pulita.
      await (db.update(db.agendaItems)..where((t) => t.id.equals(item.id)))
          .write(AgendaItemsCompanion(
        completedAt: Value(DateTime(2026, 11, 16, 23).toUtc()),
      ));
      expect(await agendas.resetIfStale(agendaId, now: now), isTrue);
      expect((await agendas.watchItems(agendaId).first).single.item.isCompleted,
          isFalse);
    });
  });
}
