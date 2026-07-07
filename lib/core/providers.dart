import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repositories/activity_repo.dart';
import '../data/repositories/agenda_repo.dart';
import '../data/services/arasaac_api.dart';
import '../data/services/tts_service.dart';

/// Il DB vive come provider root: i repository lo ricevono da qui.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final agendaRepoProvider =
    Provider<AgendaRepo>((ref) => AgendaRepo(ref.watch(databaseProvider)));

final activityRepoProvider =
    Provider<ActivityRepo>((ref) => ActivityRepo(ref.watch(databaseProvider)));

final arasaacApiProvider =
    Provider<ArasaacApi>((ref) => ArasaacApi(ref.watch(databaseProvider)));

final ttsProvider = Provider<TtsService>((ref) => TtsService());
