import 'package:drift/drift.dart';

/// Colonne comuni a tutte le entità sincronizzabili (sync-readiness).
/// PK = UUID generato client-side. Tombstone via [deletedAt].
/// [dirty] marca i record da sincronizzare (fase 2, costa nulla ora).
mixin SyncableTable on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Profilo bambino. SOLO nickname e avatar: nessun campo diagnosi, mai.
class Profiles extends Table with SyncableTable {
  /// personal
  TextColumn get displayName => text().withLength(min: 1, max: 60)();

  /// personal — FK a MediaAssets, nullable
  TextColumn get avatarAssetId => text().nullable()();

  /// JSON: {tts: bool, sounds: bool, highContrast: bool, cardSize: string,
  ///        timerStyle: "linear"|"circular" (default linear),
  ///        timelineMode: "remaining"|"history" (default remaining),
  ///        showTimes: bool (default false),
  ///        showBadges: bool (default false)}
  TextColumn get settings => text().withDefault(const Constant('{}'))();
}

enum AgendaType { daily, firstThen, sequence }

class Agendas extends Table with SyncableTable {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get type => textEnum<AgendaType>()();

  /// JSON opzionale: {weekdays: [1,2,3], time: "08:00"}
  TextColumn get scheduleHint => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

enum PictogramType { arasaac, photo, builtin }

/// Attività riusabile tra agende (es. "Colazione" usata in 3 routine).
class Activities extends Table with SyncableTable {
  TextColumn get label => text().withLength(min: 1, max: 80)();
  TextColumn get pictogramType => textEnum<PictogramType>()();

  /// ID ARASAAC (int come stringa), UUID MediaAsset, o key asset builtin
  TextColumn get pictogramRef => text()();
  TextColumn get ttsText => text().nullable()();
  TextColumn get color => text().nullable()();
}

/// Istanza di una Activity dentro un'Agenda, con posizione e timer.
class AgendaItems extends Table with SyncableTable {
  TextColumn get agendaId => text().references(Agendas, #id)();
  TextColumn get activityId => text().references(Activities, #id)();
  IntColumn get position => integer()();
  IntColumn get timerSeconds => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // ---- v3 ----

  /// Orario "di parete" locale, formato HH:mm, niente timezone.
  /// Nullable: le agende firstThen non li usano.
  TextColumn get startTime => text().nullable()();
  TextColumn get endTime => text().nullable()();

  /// Badge "dove" — JSON {type: arasaac|photo|text, ref?, label}.
  /// Sull'item e non sull'Activity: "palestra con Maria" vale per
  /// quel martedì, non per l'attività in sé. personal se type=photo.
  TextColumn get placeJson => text().nullable()();

  /// Badge "con chi" — stesso shape. personal (foto/nome di persona).
  TextColumn get companionJson => text().nullable()();
}

/// Tavola di comunicazione "I miei bisogni" (per profilo).
/// Riusa Activity: un bisogno = pittogramma + label + ttsText.
class BoardItems extends Table with SyncableTable {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get activityId => text().references(Activities, #id)();
  IntColumn get position => integer()();
}

/// Foto caricate dall'utente. File su disco, EXIF/GPS rimossi all'import.
class MediaAssets extends Table with SyncableTable {
  /// personal — path relativo a documents dir: media/<uuid>.jpg
  TextColumn get filePath => text()();
  TextColumn get mimeType => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  TextColumn get sha256 => text()();
}

/// Log completamenti per report PEI. Tabella pronta, UI post-MVP.
class CompletionLogs extends Table with SyncableTable {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get agendaId => text()();
  TextColumn get activityId => text()();
  DateTimeColumn get completedAtLog => dateTime()();
  IntColumn get durationSeconds => integer().nullable()();
}

/// Cache ricerche ARASAAC: il picker funziona offline sulle query già fatte.
class ArasaacSearchCache extends Table {
  TextColumn get query => text()();
  TextColumn get lang => text()();
  TextColumn get resultsJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {query, lang};
}
