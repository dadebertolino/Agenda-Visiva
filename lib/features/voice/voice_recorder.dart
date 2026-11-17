import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/db/database.dart';
import '../../data/services/tts_service.dart';
import '../../data/services/voice_player.dart';
import '../../l10n/app_localizations.dart';

/// Esito del dialog: [assetId] nuovo, oppure null = registrazione rimossa.
/// Il dialog chiuso senza scelta restituisce null (nessuna modifica).
class VoiceEdit {
  const VoiceEdit(this.assetId);
  final String? assetId;
}

/// Registra, sostituisce o rimuove la voce di un'attività. La registrazione
/// precedente viene cancellata dal disco se nessun'altra attività la usa.
Future<void> editActivityVoice(
    BuildContext context, WidgetRef ref, Activity activity) async {
  // Letti prima dell'await: il widget chiamante può smontarsi nel frattempo.
  final repo = ref.read(activityRepoProvider);
  final storeFuture = ref.read(mediaStoreProvider.future);

  final result = await showDialog<VoiceEdit>(
    context: context,
    builder: (_) =>
        VoiceRecorderDialog(existingAssetId: activity.audioAssetId),
  );
  if (result == null) return;

  final old = activity.audioAssetId;
  if (result.assetId == old) return;
  await repo.setAudio(activity.id, result.assetId);
  if (old != null) await (await storeFuture).deleteAudioIfUnused(old);
}

enum _Phase { idle, recording, recorded }

class VoiceRecorderDialog extends ConsumerStatefulWidget {
  const VoiceRecorderDialog({super.key, this.existingAssetId});

  final String? existingAssetId;

  @override
  ConsumerState<VoiceRecorderDialog> createState() =>
      _VoiceRecorderDialogState();
}

class _VoiceRecorderDialogState extends ConsumerState<VoiceRecorderDialog> {
  final AudioRecorder _recorder = AudioRecorder();
  _Phase _phase = _Phase.idle;
  String? _path;
  String? _error;
  int _elapsed = 0;
  Timer? _ticker;
  bool _saving = false;
  bool _saved = false;
  late final VoicePlayer _player;
  late final TtsService _tts;

  @override
  void initState() {
    super.initState();
    // Letto qui: in dispose() il ref non è più utilizzabile.
    _player = ref.read(voicePlayerProvider);
    _tts = ref.read(ttsProvider);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (_phase == _Phase.recording) unawaited(_recorder.cancel());
    unawaited(_recorder.dispose());
    unawaited(_player.stop());
    _tts.invalidateAudioSession();
    // Una registrazione non salvata non resta sul disco.
    if (!_saved) _deleteTemp();
    super.dispose();
  }

  void _deleteTemp() {
    final path = _path;
    if (path == null) return;
    final file = File(path);
    file.delete().then((_) {}, onError: (_) {}).ignore();
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (!await _recorder.hasPermission()) {
        setState(() => _error = l10n.voicePermissionDenied);
        return;
      }
      await _player.stop();
      _deleteTemp();
      final path = '${Directory.systemTemp.path}/'
          'voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
      // Mono, AAC 64 kbps: una frase di 15 s pesa ~120 KB.
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      setState(() {
        _path = path;
        _phase = _Phase.recording;
        _elapsed = 0;
        _error = null;
      });
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed++);
        if (_elapsed >= K.voiceMaxSeconds) _stop();
      });
    } catch (_) {
      if (mounted) setState(() => _error = l10n.voiceUnavailable);
    }
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    if (_phase != _Phase.recording) return;
    try {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _path = path ?? _path;
        _phase = _Phase.recorded;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _phase = _Phase.idle;
          _error = AppLocalizations.of(context)!.voiceUnavailable;
        });
      }
    }
  }

  Future<void> _listen() async {
    final player = _player;
    if (_phase == _Phase.recorded && _path != null) {
      await player.play(File(_path!));
    } else if (widget.existingAssetId != null) {
      final store = await ref.read(mediaStoreProvider.future);
      final file = await store.fileFor(widget.existingAssetId!);
      if (file != null) await player.play(file);
    }
  }

  Future<void> _save() async {
    final path = _path;
    if (path == null || _saving) return;
    setState(() => _saving = true);
    final store = await ref.read(mediaStoreProvider.future);
    final asset = await store.importAudio(File(path));
    _saved = true;
    if (mounted) Navigator.pop(context, VoiceEdit(asset.id));
  }

  String _micLabel(AppLocalizations l10n) => switch (_phase) {
        _Phase.recording => l10n.voiceStop,
        _Phase.recorded => l10n.voiceRedo,
        _Phase.idle => l10n.voiceRecord,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final recording = _phase == _Phase.recording;
    final canListen =
        _phase == _Phase.recorded || widget.existingAssetId != null;

    return AlertDialog(
      title: Text(l10n.voiceTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: _micLabel(l10n),
            child: IconButton.filled(
              iconSize: 48,
              style: IconButton.styleFrom(
                minimumSize: const Size(88, 88),
                backgroundColor: recording ? scheme.error : scheme.primary,
                foregroundColor:
                    recording ? scheme.onError : scheme.onPrimary,
              ),
              icon: Icon(recording ? Icons.stop_rounded : Icons.mic),
              tooltip: _micLabel(l10n),
              onPressed: _saving ? null : (recording ? _stop : _start),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _error ??
                (recording
                    ? l10n.voiceRecording(K.voiceMaxSeconds - _elapsed)
                    : l10n.voiceHint(K.voiceMaxSeconds)),
            textAlign: TextAlign.center,
            style: _error != null ? TextStyle(color: scheme.error) : null,
          ),
          if (canListen && !recording) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.voiceListen),
              onPressed: _listen,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.voicePrivacy,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        if (widget.existingAssetId != null && _phase == _Phase.idle)
          TextButton(
            onPressed: () => Navigator.pop(context, const VoiceEdit(null)),
            child: Text(l10n.voiceDelete,
                style: TextStyle(color: scheme.error)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.voiceCancel),
        ),
        if (_phase == _Phase.recorded)
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.voiceSave),
          ),
      ],
    );
  }
}
