import 'package:agenda_visiva/core/providers.dart';
import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/agenda_repo.dart';
import 'package:agenda_visiva/features/player/player_screen.dart';
import 'package:agenda_visiva/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Gettoni a ogni "Fatto", premio a fine agenda', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final agendas = AgendaRepo(db);
    final activities = ActivityRepo(db);

    await db
        .into(db.profiles)
        .insert(ProfilesCompanion.insert(id: 'p1', displayName: 'Test'));
    final agendaId = await agendas.create(
        profileId: 'p1', title: 'Routine', type: AgendaType.daily);
    for (final label in ['Colazione', 'Cerchio']) {
      final act = await activities.create(
          label: label, type: PictogramType.builtin, pictogramRef: 'gioco');
      await agendas.addItem(agendaId: agendaId, activityId: act);
    }
    final reward = await activities.create(
        label: 'Parco', type: PictogramType.builtin, pictogramRef: 'gioco');
    await agendas.setReward(agendaId, reward);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlayerScreen(agendaId: agendaId),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Gettoni: 0 su 2'), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));

    await tester.tap(find.text('Fatto'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Gettoni: 1 su 2'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);

    await tester.tap(find.text('Fatto'));
    await tester.pumpAndSettle();
    expect(find.text('Hai guadagnato:'), findsOneWidget);
    expect(find.text('Parco'), findsOneWidget);
    expect(find.text('Hai finito!'), findsOneWidget);
    // A fine agenda la striscia dei gettoni non serve più.
    expect(find.byIcon(Icons.star_outline_rounded), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
