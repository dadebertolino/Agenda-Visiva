import 'package:flutter_tts/flutter_tts.dart';

/// Voce italiana on-device. Fail-silent: se il TTS non è disponibile
/// (test, emulatori senza engine) l'app non deve rompersi.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> speak(String text) async {
    try {
      if (!_configured) {
        await _tts.setLanguage('it-IT');
        await _tts.setSpeechRate(0.45);
        _configured = true;
      }
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // TTS non disponibile: silenzio, nessun crash.
    }
  }
}
