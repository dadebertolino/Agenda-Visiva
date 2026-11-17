import 'package:intl/intl.dart';

/// Lunedì … domenica, nella convenzione di DateTime.weekday.
const List<int> weekdaysMonFirst = [1, 2, 3, 4, 5, 6, 7];

/// Nome breve localizzato ("lun", "Mon"). Il 1° gennaio 2024 era lunedì.
String shortWeekday(String languageCode, int weekday) {
  final day = DateTime(2024, 1, weekday);
  try {
    return DateFormat.E(languageCode).format(day);
  } catch (_) {
    // Simboli data non caricati (alcuni test): fallback inglese.
    return DateFormat.E('en').format(day);
  }
}

/// Elenco compatto "lun, mer, ven" in ordine lunedì-first.
String weekdaysSummary(String languageCode, Set<int> days) =>
    weekdaysMonFirst
        .where(days.contains)
        .map((d) => shortWeekday(languageCode, d))
        .join(', ');
