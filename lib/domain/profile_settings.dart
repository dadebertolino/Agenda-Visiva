import 'dart:convert';

/// Impostazioni per-profilo, serializzate nel campo JSON di Profile.
/// Tolleranti a JSON malformato o campi mancanti: sempre default sicuri.
class ProfileSettings {
  const ProfileSettings({
    this.tts = true,
    this.sounds = true,
    this.highContrast = false,
    this.cardSize = 'm',
    this.timerStyle = 'linear',
    this.timelineMode = 'remaining',
    this.showTimes = false,
    this.showBadges = false,
  });

  final bool tts;
  final bool sounds;
  final bool highContrast;

  /// 's' | 'm' | 'l'
  final String cardSize;

  /// 'linear' (default, feedback pilota) | 'circular' (TEACCH classico)
  final String timerStyle;

  /// 'remaining': la timeline mostra cosa resta, le card spariscono al
  /// check-off (default, feedback pilota). 'history': comportamento
  /// precedente, le completate si accumulano.
  final String timelineMode;

  /// Mostra orari startTime/endTime nel Player (rumore per alcuni,
  /// struttura per altri: per-profilo).
  final bool showTimes;

  /// Mostra badge dove/con chi sulla card corrente.
  final bool showBadges;

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
        timerStyle: map['timerStyle'] as String? ?? 'linear',
        timelineMode: map['timelineMode'] as String? ?? 'remaining',
        showTimes: map['showTimes'] as bool? ?? false,
        showBadges: map['showBadges'] as bool? ?? false,
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
        'timerStyle': timerStyle,
        'timelineMode': timelineMode,
        'showTimes': showTimes,
        'showBadges': showBadges,
      });

  ProfileSettings copyWith({
    bool? tts,
    bool? sounds,
    bool? highContrast,
    String? cardSize,
    String? timerStyle,
    String? timelineMode,
    bool? showTimes,
    bool? showBadges,
  }) =>
      ProfileSettings(
        tts: tts ?? this.tts,
        sounds: sounds ?? this.sounds,
        highContrast: highContrast ?? this.highContrast,
        cardSize: cardSize ?? this.cardSize,
        timerStyle: timerStyle ?? this.timerStyle,
        timelineMode: timelineMode ?? this.timelineMode,
        showTimes: showTimes ?? this.showTimes,
        showBadges: showBadges ?? this.showBadges,
      );
}
