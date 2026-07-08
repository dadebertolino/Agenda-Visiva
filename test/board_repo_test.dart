import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/repositories/activity_repo.dart';
import 'package:agenda_visiva/data/repositories/board_repo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tavola bisogni: add con position, remove tombstone', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final board = BoardRepo(db);
    final activities = ActivityRepo(db);
    await db.into(db.profiles).insert(
        ProfilesCompanion.insert(id: 'p1', displayName: 'Test'));

    final ids = <String>[];
    for (final label in ['Acqua', 'Bagno', 'Aiuto']) {
      final act = await activities.create(
          label: label, type: PictogramType.builtin, pictogramRef: 'acqua');
      ids.add(await board.add(profileId: 'p1', activityId: act));
    }

    var rows = await board.watch('p1').first;
    expect(rows.map((r) => r.activity.label), ['Acqua', 'Bagno', 'Aiuto']);
    expect(rows.map((r) => r.item.position), [0, 1, 2]);

    await board.remove(ids[1]);
    rows = await board.watch('p1').first;
    expect(rows.map((r) => r.activity.label), ['Acqua', 'Aiuto']);
  });
}
