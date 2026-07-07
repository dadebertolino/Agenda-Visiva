import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/db/database.dart';
import '../data/repositories/activity_repo.dart';
import '../data/repositories/agenda_repo.dart';
import '../data/repositories/profile_repo.dart';
import '../data/services/agviz_service.dart';
import '../data/services/arasaac_api.dart';
import '../data/services/media_store.dart';
import '../data/services/pdf_export.dart';
import '../data/services/tts_service.dart';
import '../domain/profile_settings.dart';

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

final profileRepoProvider =
    Provider<ProfileRepo>((ref) => ProfileRepo(ref.watch(databaseProvider)));

final arasaacApiProvider =
    Provider<ArasaacApi>((ref) => ArasaacApi(ref.watch(databaseProvider)));

final ttsProvider = Provider<TtsService>((ref) => TtsService());

final documentsDirProvider = FutureProvider<Directory>(
    (ref) => getApplicationDocumentsDirectory());

final mediaStoreProvider = FutureProvider<MediaStore>((ref) async {
  final dir = await ref.watch(documentsDirProvider.future);
  return MediaStore(ref.watch(databaseProvider), dir);
});

/// Risoluzione asset foto -> File assoluto (per il rendering).
final photoFileProvider = FutureProvider.family<File?, String>(
    (ref, assetId) async {
  final store = await ref.watch(mediaStoreProvider.future);
  return store.fileFor(assetId);
});

final pdfExportProvider = FutureProvider<PdfExportService>((ref) async {
  final media = await ref.watch(mediaStoreProvider.future);
  return PdfExportService(ref.watch(arasaacApiProvider), media);
});

final agvizProvider = FutureProvider<AgvizService>((ref) async {
  final dir = await ref.watch(documentsDirProvider.future);
  return AgvizService(ref.watch(databaseProvider), dir);
});

/// Impostazioni del profilo a cui appartiene un'agenda (usato dal player).
final agendaSettingsProvider =
    StreamProvider.family<ProfileSettings, String>((ref, agendaId) => ref
        .watch(profileRepoProvider)
        .watchSettingsJsonForAgenda(agendaId)
        .map(ProfileSettings.fromJsonString));
