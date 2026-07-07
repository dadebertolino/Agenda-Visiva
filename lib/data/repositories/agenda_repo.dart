import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../db/tables.dart';

const _uuid = Uuid();

/// Riga dell'editor: item + attività collegata (join).
typedef EditorRow = ({AgendaItem item, Activity activity});

/// Repository agende. Le feature dipendono da QUI, mai da drift direttamente.
class AgendaRepo {
  AgendaRepo(this._db);
  final AppDatabase _db;

  Stream<Agenda?> watchAgenda(String id) =>
      (_db.select(_db.agendas)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  /// Agende attive di un profilo (tombstone esclusi), ordinate.
  Stream<List<Agenda>> watchByProfile(String profileId) =>
      (_db.select(_db.agendas)
            ..where((t) => t.profileId.equals(profileId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  /// Item dell'agenda con attività collegata, in ordine di posizione.
  Stream<List<EditorRow>> watchItems(String agendaId) {
    final query = _db.select(_db.agendaItems).join([
      innerJoin(_db.activities,
          _db.activities.id.equalsExp(_db.agendaItems.activityId)),
    ])
      ..where(_db.agendaItems.agendaId.equals(agendaId) &
          _db.agendaItems.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.agendaItems.position)]);

    return query.watch().map((rows) => rows
        .map((r) => (
              item: r.readTable(_db.agendaItems),
              activity: r.readTable(_db.activities),
            ))
        .toList());
  }

  Future<String> create({
    required String profileId,
    required String title,
    required AgendaType type,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.agendas).insert(AgendasCompanion.insert(
          id: id,
          profileId: profileId,
          title: title,
          type: type,
        ));
    return id;
  }

  Future<void> updateType(String agendaId, AgendaType type) =>
      (_db.update(_db.agendas)..where((t) => t.id.equals(agendaId))).write(
        AgendasCompanion(
          type: Value(type),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});

  Future<String> addItem({
    required String agendaId,
    required String activityId,
    int? timerSeconds,
  }) async {
    final countExp = _db.agendaItems.id.count();
    final row = await (_db.selectOnly(_db.agendaItems)
          ..addColumns([countExp])
          ..where(_db.agendaItems.agendaId.equals(agendaId) &
              _db.agendaItems.deletedAt.isNull()))
        .getSingle();
    final position = row.read(countExp) ?? 0;

    final id = _uuid.v4();
    await _db.into(_db.agendaItems).insert(AgendaItemsCompanion.insert(
          id: id,
          agendaId: agendaId,
          activityId: activityId,
          position: position,
          timerSeconds: Value(timerSeconds),
        ));
    return id;
  }

  Future<void> removeItem(String itemId) =>
      (_db.update(_db.agendaItems)..where((t) => t.id.equals(itemId))).write(
        AgendaItemsCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});

  Future<void> setItemTimer(String itemId, int? seconds) =>
      (_db.update(_db.agendaItems)..where((t) => t.id.equals(itemId))).write(
        AgendaItemsCompanion(
          timerSeconds: Value(seconds),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});

  /// Riordino drag & drop: riscrive le position in transazione.
  Future<void> reorderItems(String agendaId, List<String> orderedItemIds) =>
      _db.transaction(() async {
        for (var i = 0; i < orderedItemIds.length; i++) {
          await (_db.update(_db.agendaItems)
                ..where((t) => t.id.equals(orderedItemIds[i])))
              .write(AgendaItemsCompanion(
            position: Value(i),
            updatedAt: Value(DateTime.now().toUtc()),
            dirty: const Value(true),
          ));
        }
      });

  /// Check-off dal player bambino.
  Future<void> completeItem(String itemId) =>
      (_db.update(_db.agendaItems)..where((t) => t.id.equals(itemId))).write(
        AgendaItemsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});

  /// Reset per riusare l'agenda il giorno dopo.
  Future<void> resetCompletions(String agendaId) =>
      (_db.update(_db.agendaItems)..where((t) => t.agendaId.equals(agendaId)))
          .write(AgendaItemsCompanion(
        isCompleted: const Value(false),
        completedAt: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
        dirty: const Value(true),
      )).then((_) {});

  Future<void> softDelete(String agendaId) => _db.softDeleteAgenda(agendaId);
}
