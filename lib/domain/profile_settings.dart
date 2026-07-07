import 'dart:convert';

/// Impostazioni per-profilo, serializzate nel campo JSON di Profile.
/// Tolleranti a JSON malformato o campi mancanti: sempre default sicuri.
class ProfileSettings {
  const ProfileSettings({
    this.tts = true,
    this.sounds = true,
    this.highContrast = false,
    this.cardSize = 'm',
  });

  final bool tts;
  final bool sounds;
  final bool highContrast;

  /// 's' | 'm' | 'l'
  final String cardSize;

  double get cardScale => switch (cardSize) {
        's' => 0.8,
        'l' => 1.25,
        _ => 1.0,
      };

  factory ProfileSettings.fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return const ProfileSettings();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ProfileSettings(
        tts: map['tts'] as bool? ?? true,
        sounds: map['sounds'] as bool? ?? true,
        highContrast: map['highContrast'] as bool? ?? false,
        cardSize: map['cardSize'] as String? ?? 'm',
      );
    } catch (_) {
      return const ProfileSettings();
    }
  }

  String toJsonString() => jsonEncode({
        'tts': tts,
        'sounds': sounds,
        'highContrast': highContrast,
        'cardSize': cardSize,
      });

  ProfileSettings copyWith({
    bool? tts,
    bool? sounds,
    bool? highContrast,
    String? cardSize,
  }) =>
      ProfileSettings(
        tts: tts ?? this.tts,
        sounds: sounds ?? this.sounds,
        highContrast: highContrast ?? this.highContrast,
        cardSize: cardSize ?? this.cardSize,
      );
}
