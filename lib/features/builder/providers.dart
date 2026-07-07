import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../data/repositories/agenda_repo.dart';

final agendaProvider = StreamProvider.family<Agenda?, String>(
    (ref, id) => ref.watch(agendaRepoProvider).watchAgenda(id));

final agendaItemsProvider = StreamProvider.family<List<EditorRow>, String>(
    (ref, agendaId) => ref.watch(agendaRepoProvider).watchItems(agendaId));

final recentActivitiesProvider = StreamProvider<List<Activity>>(
    (ref) => ref.watch(activityRepoProvider).watchRecent());
