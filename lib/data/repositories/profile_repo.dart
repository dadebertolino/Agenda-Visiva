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

  Future<void> rename(String id, String displayName) =>
      (_db.update(_db.profiles)..where((t) => t.id.equals(id))).write(
        ProfilesCompanion(
          displayName: Value(displayName),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});

  Stream<Profile?> watchById(String id) =>
      (_db.select(_db.profiles)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  /// JSON impostazioni del profilo proprietario di un'agenda (per il player).
  Stream<String?> watchSettingsJsonForAgenda(String agendaId) {
    final query = _db.select(_db.agendas).join([
      innerJoin(_db.profiles, _db.profiles.id.equalsExp(_db.agendas.profileId)),
    ])
      ..where(_db.agendas.id.equals(agendaId));
    return query
        .watchSingleOrNull()
        .map((row) => row?.readTable(_db.profiles).settings);
  }

  Future<void> updateSettings(String id, String settingsJson) =>
      (_db.update(_db.profiles)..where((t) => t.id.equals(id))).write(
        ProfilesCompanion(
          settings: Value(settingsJson),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});

  Future<void> softDelete(String id) =>
      (_db.update(_db.profiles)..where((t) => t.id.equals(id))).write(
        ProfilesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          dirty: const Value(true),
        ),
      ).then((_) {});
}
