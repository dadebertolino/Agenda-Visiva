/// Costanti di prodotto. Vincoli NON negoziabili in commento.
abstract final class K {
  /// Touch target minimo modalità bambino (sopra WCAG per motricità target).
  static const double childMinTouchTarget = 64;

  /// Debounce ricerca ARASAAC: mai una chiamata per keystroke.
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Risoluzioni immagini ARASAAC.
  static const int resThumb = 300;
  static const int resUi = 500;
  static const int resPdf = 2500;

  /// Durata pressione lunga per il gate adulto.
  static const Duration adultGateLongPress = Duration(seconds: 3);

  static const String schemaVersionExport = '1';
}
