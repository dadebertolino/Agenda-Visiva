import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

const _uuid = Uuid();

typedef BoardRow = ({BoardItem item, Activity activity});

/// Tavola comunicazione bisogni: pochi elementi, accesso immediato.
class BoardRepo {
  BoardRepo(this._db);
  final AppDatabase _db;

  Stream<List<BoardRow>> watch(String profileId) {
    final query = _db.select(_db.boardItems).join([
      innerJoin(_db.activities,
          _db.activities.id.equalsExp(_db.boardItems.activityId)),
    ])
      ..where(_db.boardItems.profileId.equals(profileId) &
          _db.boardItems.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.boardItems.position)]);
    return query.watch().map((rows) => rows
        .map((r) => (
              item: r.readTable(_db.boardItems),
              activity: r.readTable(_db.activities),
            ))
        .toList());
  }

  Future<String> add({
    required String profileId,
    required String activityId,
  }) async {
    final countExp = _db.boardItems.id.count();
    final row = await (_db.selectOnly(_db.boardItems)
          ..addColumns([countExp])
          ..where(_db.boardItems.profileId.equals(profileId) &
              _db.boardItems.deletedAt.isNull()))
        .getSingle();
    final position = row.read(countExp) ?? 0;

    final id = _uuid.v4();
    await _db.into(_db.boardItems).insert(BoardItemsCompanion.insert(
          id: id,
          profileId: profileId,
          activityId: activityId,
          position: position,
        ));
    return id;
  }

  Future<void> remove(String itemId) =>
      (_db.update(_db.boardItems)..where((t) => t.id.equals(itemId))).write(
        BoardItemsCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});
}
