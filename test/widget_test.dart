import 'package:agenda_visiva/core/providers.dart';
import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home: empty state, creazione profilo e agenda', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const AgendaVisivaApp(),
    ));
    await tester.pumpAndSettle();

    // Empty state
    expect(find.text('Crea il primo profilo per iniziare'), findsOneWidget);

    // Crea profilo
    await tester.tap(find.text('Nuovo profilo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Sofia');
    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();
    expect(find.text('Sofia'), findsOneWidget);

    // Entra nel profilo -> lista agende vuota
    await tester.tap(find.text('Sofia'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nessuna agenda'), findsOneWidget);

    // Cleanup timer drift
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
