import 'package:flutter_tts/flutter_tts.dart';

/// Voce italiana on-device. Fail-silent: se il TTS non è disponibile
/// (test, emulatori senza engine) l'app non deve rompersi.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  String? _configuredLocale;

  Future<void> _configure(String locale) async {
    // iOS: categoria playback = suona anche con interruttore silenzioso,
    // istanza condivisa per non farsi silenziare da altre app.
    try {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.duckOthers],
      );
    } catch (_) {
      // Android o piattaforma senza queste API: ok così.
    }
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _configuredLocale = locale;
  }

  Future<void> speak(String text, {String locale = 'it-IT'}) async {
    try {
      if (_configuredLocale != locale) await _configure(locale);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // TTS non disponibile: silenzio, nessun crash.
    }
  }

  /// Da chiamare dopo una registrazione: su iOS il registratore lascia la
  /// sessione audio in playAndRecord (auricolare); al prossimo speak la
  /// categoria playback viene reimpostata.
  void invalidateAudioSession() => _configuredLocale = null;

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
