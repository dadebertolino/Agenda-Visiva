// Screenshot per gli store, generati dalla vera app (motore, font e
// pittogrammi ARASAAC reali) con dati di esempio e nomi di fantasia.
//
//   flutter test integration_test/store_screenshots_test.dart -d macos
//
// I PNG finiscono nella cartella documenti dell'app (sandbox macOS:
// ~/Library/Containers/it.davidebertolino.agendaVisiva/Data/Documents/
// store_screenshots). Il DB è in memoria: i dati reali non vengono toccati.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:agenda_visiva/core/providers.dart';
import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/db/tables.dart';
import 'package:agenda_visiva/data/services/arasaac_api.dart';
import 'package:agenda_visiva/features/builder/agenda_editor_screen.dart';
import 'package:agenda_visiva/features/comunicazione/bisogni_screen.dart';
import 'package:agenda_visiva/features/player/player_screen.dart';
import 'package:agenda_visiva/features/profiles/home_screen.dart';
import 'package:agenda_visiva/features/voice/voice_recorder.dart';
import 'package:agenda_visiva/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Mac App Store: 16:10. 1440x900 logici a 2x = 2880x1800.
const _logical = Size(1440, 900);
const _pixelRatio = 2.0;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot Mac App Store', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final demo = await _seed(db);
    final outDir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/store_screenshots');
    await outDir.create(recursive: true);

    Future<void> shot(String name, Widget home,
        {Future<void> Function()? before}) async {
      // GlobalKey nuova per scatto: riusarla sposterebbe nel nuovo albero
      // anche il Navigator precedente (con i dialog aperti).
      final shotKey = GlobalKey();
      await tester.pumpWidget(_frame(db, home, name, shotKey));
      await _settleWithNetwork(tester);
      if (before != null) {
        await before();
        await _settleWithNetwork(tester);
      }
      final boundary =
          tester.renderObject(find.byKey(shotKey)) as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('${outDir.path}/$name.png')
          .writeAsBytes(png!.buffer.asUint8List());
    }

    await shot('01_oggi', ProfileAgendasScreen(profile: demo.profile));

    await shot('02_editor', AgendaEditorScreen(agendaId: demo.morning),
        before: () async {
      await tester.tap(find.byIcon(Icons.event_repeat));
    });

    await _completeFirst(db, demo.morning, 2);
    await shot('03_modalita_bambino', PlayerScreen(agendaId: demo.morning));

    await shot('04_bisogni', BisogniScreen(profileId: demo.profile.id));

    await shot('05_voce', AgendaEditorScreen(agendaId: demo.evening),
        before: () async {
      final context = tester.element(find.byType(AgendaEditorScreen));
      // Il dialog resta aperto per lo scatto: niente await.
      unawaited(showDialog<void>(
          context: context, builder: (_) => const VoiceRecorderDialog()));
    });

    await _completeFirst(db, demo.morning, 99);
    await shot('06_premio', PlayerScreen(agendaId: demo.morning));

    await shot('07_adesso_dopo', PlayerScreen(agendaId: demo.firstThen));

    // ignore: avoid_print
    print('SCREENSHOT_DIR=${outDir.path}');
    await tester.pumpWidget(const SizedBox.shrink());
    await db.close();
  });
}

/// App a dimensione fissa 16:10. FittedBox: la superficie entra tutta nella
/// finestra reale, così i tocchi arrivano ovunque; toImage cattura comunque
/// a risoluzione piena. La key per scatto forza un albero nuovo (niente
/// dialog o route ereditati dallo scatto precedente).
Widget _frame(AppDatabase db, Widget home, String name, GlobalKey shotKey) =>
    ProviderScope(
      key: ValueKey(name),
      overrides: [databaseProvider.overrideWithValue(db)],
      child: FittedBox(
        child: SizedBox.fromSize(
          size: _logical,
          child: RepaintBoundary(
            key: shotKey,
            child: MediaQuery(
              data: const MediaQueryData(
                  size: _logical, devicePixelRatio: _pixelRatio),
              child: MaterialApp(
                locale: const Locale('it'),
                debugShowCheckedModeBanner: false,
                theme:
                    ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: home,
              ),
            ),
          ),
        ),
      ),
    );

/// Le immagini ARASAAC arrivano dalla rete: tempo reale, non fake async.
Future<void> _settleWithNetwork(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
  await tester.pump(const Duration(milliseconds: 700));
}

Future<void> _completeFirst(AppDatabase db, String agendaId, int n) async {
  final items = await (db.select(db.agendaItems)
        ..where((t) => t.agendaId.equals(agendaId))
        ..orderBy([(t) => OrderingTerm.asc(t.position)]))
      .get();
  for (final item in items.take(n)) {
    await (db.update(db.agendaItems)..where((t) => t.id.equals(item.id)))
        .write(AgendaItemsCompanion(
      isCompleted: const Value(true),
      completedAt: Value(DateTime.now().toUtc()),
    ));
  }
}

typedef _Demo = ({
  Profile profile,
  String morning,
  String evening,
  String firstThen,
});

Future<_Demo> _seed(AppDatabase db) async {
  final api = ArasaacApi(db);
  var n = 0;
  String id() => 'demo-${n++}';

  /// Primo risultato ARASAAC (filtro bambini incluso) per la parola.
  Future<String> activity(String label, String query, {String? audio}) async {
    final results = await api.search(query);
    final aid = id();
    await db.into(db.activities).insert(ActivitiesCompanion.insert(
          id: aid,
          label: label,
          pictogramType:
              results.isEmpty ? PictogramType.builtin : PictogramType.arasaac,
          pictogramRef: results.isEmpty ? 'gioco' : '${results.first.id}',
          audioAssetId: Value(audio),
        ));
    return aid;
  }

  Future<String> agenda(
      String title, AgendaType type, List<int> days, int order) async {
    final aid = id();
    await db.into(db.agendas).insert(AgendasCompanion.insert(
          id: aid,
          profileId: 'leo',
          title: title,
          type: type,
          sortOrder: Value(order),
          scheduleHint:
              Value(days.isEmpty ? null : '{"weekdays":${days.toString()}}'),
        ));
    return aid;
  }

  Future<void> item(String agendaId, String activityId, int pos,
          {String? start,
          String? end,
          int? timer,
          String? place,
          String? who}) =>
      db.into(db.agendaItems).insert(AgendaItemsCompanion.insert(
            id: id(),
            agendaId: agendaId,
            activityId: activityId,
            position: pos,
            startTime: Value(start),
            endTime: Value(end),
            timerSeconds: Value(timer),
            placeJson: Value(
                place == null ? null : '{"type":"text","label":"$place"}'),
            companionJson:
                Value(who == null ? null : '{"type":"text","label":"$who"}'),
          ));

  await db
      .into(db.profiles)
      .insert(ProfilesCompanion.insert(id: 'leo', displayName: 'Leo'));
  // Leo vede orari e "dove/con chi" in modalità bambino.
  await (db.update(db.profiles)..where((t) => t.id.equals('leo'))).write(
      const ProfilesCompanion(
          settings: Value('{"showTimes":true,"showBadges":true}')));

  // Voce registrata finta: basta il riferimento per l'etichetta in editor.
  await db.into(db.mediaAssets).insert(MediaAssetsCompanion.insert(
      id: 'voice-demo',
      filePath: 'media/voice-demo.m4a',
      mimeType: 'audio/mp4',
      width: 0,
      height: 0,
      sha256: ''));

  final morning =
      await agenda('Mattina a scuola', AgendaType.daily, [1, 2, 3, 4, 5], 0);
  final evening = await agenda('Prima della nanna', AgendaType.sequence, [], 1);
  final firstThen =
      await agenda('Compiti, poi gioco', AgendaType.firstThen, [], 2);
  await agenda('Piscina', AgendaType.daily, [6], 3);

  final steps = [
    ('Appendere lo zaino', 'zaino', '08:30', '08:40', null),
    ('Lavare le mani', 'lavarsi le mani', '08:40', '08:50', null),
    ('Disegno', 'disegnare', '09:00', '09:30', 15 * 60),
    ('Merenda', 'merenda', '10:00', '10:20', null),
    ('Giardino', 'giardino', '10:30', '11:15', null),
    ('Pranzo', 'pranzo', '12:00', '12:45', null),
  ];
  for (var i = 0; i < steps.length; i++) {
    final (label, q, s, e, timer) = steps[i];
    await item(morning, await activity(label, q), i,
        start: s,
        end: e,
        timer: timer,
        place: i == 2 ? 'Aula verde' : null,
        who: i == 2 ? 'Maestra Anna' : null);
  }
  final reward = await activity('Parco giochi', 'parco giochi');
  await (db.update(db.agendas)..where((t) => t.id.equals(morning)))
      .write(AgendasCompanion(rewardActivityId: Value(reward)));

  final night = [
    ('Cena', 'cena'),
    ('Lavare i denti', 'lavarsi i denti'),
    ('Pigiama', 'pigiama'),
    ('Leggere un libro', 'leggere'),
    ('Dormire', 'dormire'),
  ];
  for (var i = 0; i < night.length; i++) {
    final (label, q) = night[i];
    await item(evening,
        await activity(label, q, audio: i.isEven ? 'voice-demo' : null), i);
  }

  await item(firstThen, await activity('Compiti', 'scrivere'), 0,
      timer: 20 * 60);
  await item(
      firstThen, await activity('Gioco con le costruzioni', 'costruzioni'), 1);

  final needs = [
    ('Acqua', 'acqua'),
    ('Bagno', 'bagno'),
    ('Aiuto', 'aiuto'),
    ('Pausa', 'pausa'),
    ('Ho fame', 'fame'),
    ('Mi fa male', 'dolore'),
    ('Abbraccio', 'abbraccio'),
    ('Sono stanco', 'stanco'),
  ];
  for (var i = 0; i < needs.length; i++) {
    final (label, q) = needs[i];
    await db.into(db.boardItems).insert(BoardItemsCompanion.insert(
        id: id(),
        profileId: 'leo',
        activityId: await activity(label, q),
        position: i));
  }

  final profile = await (db.select(db.profiles)
        ..where((t) => t.id.equals('leo')))
      .getSingle();
  return (
    profile: profile,
    morning: morning,
    evening: evening,
    firstThen: firstThen,
  );
}
