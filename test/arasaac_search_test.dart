import 'dart:convert';

import 'package:agenda_visiva/data/db/database.dart';
import 'package:agenda_visiva/data/services/arasaac_api.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  List<Map<String, dynamic>> fakeResults() => [
        {
          '_id': 100,
          'keywords': [
            {'keyword': 'colazione'}
          ],
          'sex': false,
          'violence': false,
        },
        {
          '_id': 200,
          'keywords': [
            {'keyword': 'inappropriato'}
          ],
          'sex': true,
          'violence': false,
        },
      ];

  test('il filtro sex/violence è applicato SEMPRE', () async {
    final api = ArasaacApi(db,
        client: MockClient(
            (req) async => http.Response(jsonEncode(fakeResults()), 200)));

    final results = await api.search('colazione');
    expect(results.map((p) => p.id), [100]);
  });

  test('la seconda ricerca identica usa la cache, non la rete', () async {
    var calls = 0;
    final api = ArasaacApi(db, client: MockClient((req) async {
      calls++;
      return http.Response(jsonEncode(fakeResults()), 200);
    }));

    await api.search('colazione');
    await api.search('colazione');
    expect(calls, 1);
  });

  test('404 = zero risultati, senza eccezioni', () async {
    final api = ArasaacApi(db,
        client: MockClient((req) async => http.Response('not found', 404)));
    expect(await api.search('xyzabc'), isEmpty);
  });
}
