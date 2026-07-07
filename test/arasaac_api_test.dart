import 'package:agenda_visiva/data/services/arasaac_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArasaacApi.imageUrl', () {
    test('URL deterministico a colori', () {
      expect(
        ArasaacApi.imageUrl(2349, res: 500),
        'https://static.arasaac.org/pictograms/2349/2349_500.png',
      );
    });

    test('variante nocolor', () {
      expect(
        ArasaacApi.imageUrl(2349, res: 2500, color: false),
        'https://static.arasaac.org/pictograms/2349/2349_nocolor_2500.png',
      );
    });
  });

  group('Filtro bambini', () {
    test('fromJson legge i flag sex/violence', () {
      final p = ArasaacPictogram.fromJson({
        '_id': 1,
        'keywords': [
          {'keyword': 'test'}
        ],
        'sex': true,
        'violence': false,
      });
      expect(p.sex, isTrue);
    });
  });
}
