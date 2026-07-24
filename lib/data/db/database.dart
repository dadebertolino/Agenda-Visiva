import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Agendas,
    Activities,
    AgendaItems,
    MediaAssets,
    CompletionLogs,
    ArasaacSearchCache,
    BoardItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(boardItems);
          if (from < 3) {
            await m.addColumn(agendaItems, agendaItems.startTime);
            await m.addColumn(agendaItems, agendaItems.endTime);
            await m.addColumn(agendaItems, agendaItems.placeJson);
            await m.addColumn(agendaItems, agendaItems.companionJson);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'agenda_visiva');
}

/// Regole trasversali sync-readiness: ogni write aggiorna updatedAt+dirty,
/// ogni delete è un tombstone. Usare SEMPRE questi helper nei repository.
extension SyncWrites on AppDatabase {
  Future<int> touchProfile(String id) =>
      (update(profiles)..where((t) => t.id.equals(id))).write(
        ProfilesCompanion(
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      );

  Future<int> softDeleteAgenda(String id) =>
      (update(agendas)..where((t) => t.id.equals(id))).write(
        AgendasCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      );
}
