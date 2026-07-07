import 'package:agenda_visiva/domain/profile_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default sicuri con JSON vuoto o malformato', () {
    for (final raw in [null, '', '{}', 'non-json', '[1,2]']) {
      final s = ProfileSettings.fromJsonString(raw);
      expect(s.tts, isTrue);
      expect(s.cardSize, 'm');
      expect(s.cardScale, 1.0);
    }
  });

  test('roundtrip JSON', () {
    const original = ProfileSettings(
        tts: false, sounds: false, highContrast: true, cardSize: 'l');
    final restored =
        ProfileSettings.fromJsonString(original.toJsonString());
    expect(restored.tts, isFalse);
    expect(restored.highContrast, isTrue);
    expect(restored.cardScale, 1.25);
  });
}
