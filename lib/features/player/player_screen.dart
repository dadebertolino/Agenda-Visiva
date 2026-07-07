import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/widgets/pictogram_thumb.dart';
import '../../data/db/tables.dart';
import '../../data/repositories/agenda_repo.dart';
import '../builder/providers.dart';

/// Modalità bambino: full-screen, un solo elemento dominante,
/// back bloccato, uscita solo via gate adulto.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.agendaId});

  final String agendaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agenda = ref.watch(agendaProvider(agendaId)).valueOrNull;
    final items = ref.watch(agendaItemsProvider(agendaId)).valueOrNull ?? [];

    if (agenda == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentIndex = items.indexWhere((r) => !r.item.isCompleted);
    final done = currentIndex == -1 && items.isNotEmpty;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(title: agenda.title),
              Expanded(
                child: done
                    ? _EndView(agendaId: agendaId)
                    : items.isEmpty
                        ? const Center(child: Text('Agenda vuota'))
                        : agenda.type == AgendaType.firstThen
                            ? _FirstThenView(items: items, currentIndex: currentIndex)
                            : _DailyView(items: items, currentIndex: currentIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra minima: titolo + lucchetto gate. Long-press → domanda aritmetica.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onLongPress: () => _showAdultGate(context),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.lock_outline, size: 20, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdultGate(BuildContext context) async {
    final rnd = Random();
    final a = 3 + rnd.nextInt(7);
    final b = 3 + rnd.nextInt(7);
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Solo per adulti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quanto fa $a × $b?'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              onSubmitted: (v) =>
                  Navigator.pop(dialogContext, int.tryParse(v) == a * b),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext,
                int.tryParse(controller.text) == a * b),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) Navigator.pop(context);
  }
}

/// Vista giornata/sequenza: completate in alto (piccole), card ADESSO
/// dominante al centro, prossima attività sotto.
class _DailyView extends ConsumerWidget {
  const _DailyView({required this.items, required this.currentIndex});
  final List<EditorRow> items;
  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = items.take(currentIndex).toList();
    final current = items[currentIndex];
    final next =
        currentIndex + 1 < items.length ? items[currentIndex + 1] : null;

    return Column(
      children: [
        if (completed.isNotEmpty)
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: completed.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Opacity(
                opacity: 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PictogramThumb(
                      type: completed[i].activity.pictogramType,
                      pictogramRef: completed[i].activity.pictogramRef,
                      size: 44,
                    ),
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: Center(child: _CurrentCard(row: current))),
        if (next != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Opacity(
              opacity: 0.65,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Poi: ',
                      style: Theme.of(context).textTheme.titleMedium),
                  PictogramThumb(
                    type: next.activity.pictogramType,
                    pictogramRef: next.activity.pictogramRef,
                    size: 40,
                  ),
                  const SizedBox(width: 8),
                  Text(next.activity.label,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Vista Prima–Poi: due card affiancate, si completa solo "Prima".
class _FirstThenView extends ConsumerWidget {
  const _FirstThenView({required this.items, required this.currentIndex});
  final List<EditorRow> items;
  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = items[currentIndex];
    final next =
        currentIndex + 1 < items.length ? items[currentIndex + 1] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Prima', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _CurrentCard(row: current, compact: true),
          ],
        ),
        if (next != null)
          Opacity(
            opacity: 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Poi', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                PictogramThumb(
                  type: next.activity.pictogramType,
                  pictogramRef: next.activity.pictogramRef,
                  size: 140,
                ),
                const SizedBox(height: 12),
                Text(next.activity.label,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
      ],
    );
  }
}

/// Card dell'attività corrente: pittogramma grande, TTS al tap,
/// timer ring se impostato, bottone Fatto >= 64px.
class _CurrentCard extends ConsumerWidget {
  const _CurrentCard({required this.row, this.compact = false});
  final EditorRow row;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = compact ? 140.0 : 200.0;
    final timer = row.item.timerSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => ref
              .read(ttsProvider)
              .speak(row.activity.ttsText ?? row.activity.label),
          child: PictogramThumb(
            type: row.activity.pictogramType,
            pictogramRef: row.activity.pictogramRef,
            size: size,
          ),
        ),
        const SizedBox(height: 16),
        Text(row.activity.label,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        if (timer != null) ...[
          _TimerRing(key: ValueKey(row.item.id), seconds: timer),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: Size(compact ? 140 : 200, K.childMinTouchTarget),
            textStyle: const TextStyle(fontSize: 20),
          ),
          icon: const Icon(Icons.check, size: 28),
          label: const Text('Fatto'),
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(agendaRepoProvider).completeItem(row.item.id);
          },
        ),
      ],
    );
  }
}

/// Anello analogico che si svuota: rappresentazione TEACCH-friendly,
/// niente cifre.
class _TimerRing extends StatefulWidget {
  const _TimerRing({super.key, required this.seconds});
  final int seconds;

  @override
  State<_TimerRing> createState() => _TimerRingState();
}

class _TimerRingState extends State<_TimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.seconds),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: const Size(56, 56),
        painter: _RingPainter(
          fraction: 1 - _controller.value,
          color: Theme.of(context).colorScheme.tertiary,
          track: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(
      {required this.fraction, required this.color, required this.track});
  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = track;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * fraction,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

/// Fine agenda: rinforzo visivo semplice, non sovrastimolante.
class _EndView extends ConsumerWidget {
  const _EndView({required this.agendaId});
  final String agendaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              size: 140, color: Colors.amber.shade400),
          const SizedBox(height: 16),
          Text('Hai finito!',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 32),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
                minimumSize: const Size(200, K.childMinTouchTarget)),
            onPressed: () =>
                ref.read(agendaRepoProvider).resetCompletions(agendaId),
            child: const Text('Ricomincia', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
