import 'package:agenda_visiva/core/providers.dart';
import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/main.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('L\'app parte e mostra l\'editor col seed demo', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const AgendaVisivaApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Routine mattina'), findsOneWidget);
    expect(find.text('Colazione'), findsWidgets);

    // Smonta l'albero nel test: fa scattare i timer di cleanup di drift.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
