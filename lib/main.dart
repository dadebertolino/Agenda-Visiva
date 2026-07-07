import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'core/providers.dart';
import 'data/db/database.dart';
import 'data/db/tables.dart';
import 'features/builder/agenda_editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AgendaVisivaApp()));
}

/// Seed dev: al primo avvio crea profilo + agenda demo e ne restituisce l'id.
/// Sparirà quando arriveranno Home profili e lista agende.
final demoAgendaProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  final existing = await (db.select(db.agendas)
        ..where((t) => t.deletedAt.isNull())
        ..limit(1))
      .getSingleOrNull();
  if (existing != null) return existing.id;

  const uuid = Uuid();
  final profileId = uuid.v4();
  await db.into(db.profiles).insert(
      ProfilesCompanion.insert(id: profileId, displayName: 'Demo'));

  final agendaId = uuid.v4();
  await db.into(db.agendas).insert(AgendasCompanion.insert(
        id: agendaId,
        profileId: profileId,
        title: 'Routine mattina',
        type: AgendaType.daily,
      ));

  const seedActivities = [
    ('Sveglia', 'sveglia'),
    ('Colazione', 'colazione'),
    ('Cerchio', 'cerchio'),
  ];
  for (var i = 0; i < seedActivities.length; i++) {
    final activityId = uuid.v4();
    await db.into(db.activities).insert(ActivitiesCompanion.insert(
          id: activityId,
          label: seedActivities[i].$1,
          pictogramType: PictogramType.builtin,
          pictogramRef: seedActivities[i].$2,
        ));
    await db.into(db.agendaItems).insert(AgendaItemsCompanion.insert(
          id: uuid.v4(),
          agendaId: agendaId,
          activityId: activityId,
          position: i,
        ));
  }
  return agendaId;
});

class AgendaVisivaApp extends ConsumerWidget {
  const AgendaVisivaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoAgenda = ref.watch(demoAgendaProvider);

    return MaterialApp(
      title: 'Agenda Visiva',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: demoAgenda.when(
        data: (id) => AgendaEditorScreen(agendaId: id),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Errore: $e'))),
      ),
    );
  }
}
