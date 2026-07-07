import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../db/tables.dart';

const _uuid = Uuid();

class ActivityRepo {
  ActivityRepo(this._db);
  final AppDatabase _db;

  Future<String> create({
    required String label,
    required PictogramType type,
    required String pictogramRef,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.activities).insert(ActivitiesCompanion.insert(
          id: id,
          label: label,
          pictogramType: type,
          pictogramRef: pictogramRef,
        ));
    return id;
  }

  /// Attività recenti per la striscia quick-add dell'editor.
  Stream<List<Activity>> watchRecent({int limit = 12}) =>
      (_db.select(_db.activities)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
            ..limit(limit))
          .watch();
}
