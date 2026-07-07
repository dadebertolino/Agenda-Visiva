import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

const _uuid = Uuid();

class ProfileRepo {
  ProfileRepo(this._db);
  final AppDatabase _db;

  Stream<List<Profile>> watchAll() => (_db.select(_db.profiles)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();

  Future<String> create({required String displayName}) async {
    final id = _uuid.v4();
    await _db.into(_db.profiles).insert(
        ProfilesCompanion.insert(id: id, displayName: displayName));
    return id;
  }

  Future<void> softDelete(String id) =>
      (_db.update(_db.profiles)..where((t) => t.id.equals(id))).write(
        ProfilesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});
}
