import 'dart:convert';

/// Pianificazione settimanale di un'agenda, nel campo JSON scheduleHint.
/// weekdays usa la convenzione di DateTime.weekday: 1 = lunedì … 7 = domenica.
/// Tollerante a JSON malformato; preserva i campi che non conosce (es. time).
class ScheduleHint {
  const ScheduleHint({this.weekdays = const {}, this.extra = const {}});

  final Set<int> weekdays;

  /// Altri campi già presenti nel JSON (es. "time"): riscritti invariati.
  final Map<String, dynamic> extra;

  bool get isEmpty => weekdays.isEmpty;

  bool appliesTo(DateTime day) => weekdays.contains(day.weekday);

  factory ScheduleHint.fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return const ScheduleHint();
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final days = (map.remove('weekdays') as List? ?? const [])
          .whereType<num>()
          .map((d) => d.toInt())
          .where((d) => d >= DateTime.monday && d <= DateTime.sunday)
          .toSet();
      return ScheduleHint(weekdays: days, extra: map);
    } catch (_) {
      return const ScheduleHint();
    }
  }

  /// null se non resta nulla da salvare: il campo torna vuoto nel DB.
  String? toJsonString() {
    if (weekdays.isEmpty && extra.isEmpty) return null;
    return jsonEncode({
      ...extra,
      if (weekdays.isNotEmpty) 'weekdays': (weekdays.toList()..sort()),
    });
  }

  ScheduleHint withWeekdays(Set<int> days) =>
      ScheduleHint(weekdays: days, extra: extra);
}
