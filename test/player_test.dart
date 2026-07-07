import 'package:agenda_visiva/core/providers.dart';
import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/agenda_repo.dart';
import 'package:agenda_visiva/features/player/player_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Il player avanza al check-off e mostra la fine',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final agendas = AgendaRepo(db);
    final activities = ActivityRepo(db);

    await db.into(db.profiles).insert(
        ProfilesCompanion.insert(id: 'p1', displayName: 'Test'));
    final agendaId = await agendas.create(
        profileId: 'p1', title: 'Routine', type: AgendaType.daily);
    for (final label in ['Colazione', 'Cerchio']) {
      final act = await activities.create(
          label: label,
          type: PictogramType.builtin,
          pictogramRef: 'gioco');
      await agendas.addItem(agendaId: agendaId, activityId: act);
    }

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: PlayerScreen(agendaId: agendaId)),
    ));
    await tester.pumpAndSettle();

    // Prima attività dominante, la seconda è "Poi".
    expect(find.text('Colazione'), findsOneWidget);
    expect(find.textContaining('Poi'), findsOneWidget);

    // Check-off → avanza.
    await tester.tap(find.text('Fatto'));
    await tester.pumpAndSettle();
    expect(find.text('Cerchio'), findsOneWidget);

    // Ultimo check-off → schermata di fine.
    await tester.tap(find.text('Fatto'));
    await tester.pumpAndSettle();
    expect(find.text('Hai finito!'), findsOneWidget);

    // Ricomincia → si riparte dalla prima.
    await tester.tap(find.text('Ricomincia'));
    await tester.pumpAndSettle();
    expect(find.text('Colazione'), findsOneWidget);

    // Cleanup timer drift (pattern noto drift+riverpod nei widget test).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
