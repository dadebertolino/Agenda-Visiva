import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

import 'tts_service.dart';

/// Riproduzione delle voci registrate. Fail-silent come il TTS: se l'audio
/// non parte, il chiamante ripiega sulla sintesi vocale.
/// Il player nativo si crea solo al primo uso (test e dispositivi senza
/// audio non lo istanziano mai).
class VoicePlayer {
  AudioPlayer? _player;

  /// Categoria playback su iOS: suona anche con l'interruttore silenzioso e
  /// sull'altoparlante, anche subito dopo una registrazione (che lascia la
  /// sessione in playAndRecord, instradata sull'auricolare).
  static final _context = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {AVAudioSessionOptions.duckOthers},
    ),
  );

  Future<bool> play(File file) async {
    try {
      if (!await file.exists()) return false;
      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.setAudioContext(_context);
      await player.play(DeviceFileSource(file.path));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = null;
  }
}

/// Un'unica porta per "fai parlare questa attività": voce registrata
/// dall'adulto se c'è, altrimenti sintesi vocale. Le due non si
/// sovrappongono mai.
class ActivitySpeaker {
  ActivitySpeaker(this._tts, this._voice, this._fileFor);

  final TtsService _tts;
  final VoicePlayer _voice;
  final Future<File?> Function(String assetId) _fileFor;

  Future<void> speak({
    required String text,
    required String locale,
    String? audioAssetId,
  }) async {
    if (audioAssetId != null) {
      try {
        final file = await _fileFor(audioAssetId);
        if (file != null) {
          await _tts.stop();
          if (await _voice.play(file)) return;
        }
      } catch (_) {
        // File mancante o media store non pronto: ripiega sul TTS.
      }
    }
    await _voice.stop();
    await _tts.speak(text, locale: locale);
  }
}
