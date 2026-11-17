import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../core/widgets/pictogram_thumb.dart';
import '../../data/db/tables.dart';
import '../../data/db/database.dart';
import '../../data/repositories/agenda_repo.dart';
import '../../domain/item_badge.dart';
import '../../domain/profile_settings.dart';
import '../../l10n/app_localizations.dart';
import '../builder/providers.dart';
import '../comunicazione/bisogni_screen.dart';

/// Apre la modalità bambino. Se l'agenda ha spunte di un giorno
/// precedente riparte pulita: la routine del lunedì non si presenta il
/// lunedì dopo già "finita".
Future<void> openPlayer(
    BuildContext context, WidgetRef ref, String agendaId) async {
  final navigator = Navigator.of(context);
  await ref.read(agendaRepoProvider).resetIfStale(agendaId);
  await navigator.push(
    MaterialPageRoute<void>(builder: (_) => PlayerScreen(agendaId: agendaId)),
  );
}

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

    final settings = ref.watch(agendaSettingsProvider(agendaId)).valueOrNull ??
      const ProfileSettings();
    final l10n = AppLocalizations.of(context)!;
    final baseTheme = Theme.of(context);
    final playerTheme = settings.highContrast
      ? baseTheme.copyWith(
        colorScheme: baseTheme.brightness == Brightness.dark
          ? const ColorScheme.highContrastDark()
          : const ColorScheme.highContrastLight(),
        )
      : baseTheme;
    final currentIndex = items.indexWhere((r) => !r.item.isCompleted);
    final done = currentIndex == -1 && items.isNotEmpty;
    final rewardId = agenda.rewardActivityId;
    final reward = rewardId == null
        ? null
        : ref.watch(activityProvider(rewardId)).valueOrNull;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // Back di sistema/gesto: non esce, ma spiega come si fa.
        if (!didPop) _showExitHint(context);
      },
      child: Theme(
        data: playerTheme,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(title: agenda.title, profileId: agenda.profileId),
                if (reward != null && items.isNotEmpty && !done)
                  _TokenBoard(
                    total: items.length,
                    earned: items.where((r) => r.item.isCompleted).length,
                    reward: reward,
                  ),
                Expanded(
                  child: done
                      ? _EndView(agendaId: agendaId, reward: reward)
                      : items.isEmpty
                          ? Center(child: Text(l10n.playerEmpty))
                          : agenda.type == AgendaType.firstThen
                              ? _FirstThenView(
                                  items: items, currentIndex: currentIndex)
                              : _DailyView(
                                  items: items, currentIndex: currentIndex),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra minima: gate adulto + titolo. Per uscire dalla modalità bambino
/// si tiene premuta la freccia per [K.adultGateLongPress]: un tocco normale
/// non basta, così il bambino non torna all'editor da solo.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.profileId});
  final String title;
  final String profileId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _AdultGateButton(onUnlocked: () => Navigator.of(context).pop()),
          const SizedBox(width: 4),
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            tooltip: l10n.playerNeeds,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => BisogniScreen(profileId: profileId)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Suggerimento su come uscire: mostrato al tocco breve e al back di sistema.
void _showExitHint(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(l10n.playerExitHint),
      duration: const Duration(seconds: 2),
    ));
}

/// Gate adulto: la freccia esce solo se tenuta premuta per
/// [K.adultGateLongPress]. Un anello si riempie durante la pressione;
/// se si rilascia prima, non esce e appare il suggerimento.
class _AdultGateButton extends StatefulWidget {
  const _AdultGateButton({required this.onUnlocked});
  final VoidCallback onUnlocked;

  @override
  State<_AdultGateButton> createState() => _AdultGateButtonState();
}

class _AdultGateButtonState extends State<_AdultGateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: K.adultGateLongPress,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        widget.onUnlocked();
      }
    });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() => _controller.forward();

  void _cancelHold() {
    // Se il gate si è già completato l'uscita è in corso: non fare nulla
    // (il widget sta per essere smontato).
    if (_controller.isCompleted) return;
    // isAnimating è true già subito dopo forward(), anche prima del primo
    // frame: così un tocco rapido — dove value è ancora 0 — viene comunque
    // fermato, altrimenti il controller proseguirebbe fino a uscire da solo.
    if (_controller.isAnimating) {
      _controller.reset();
      _showExitHint(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Listener (eventi puntatore grezzi) e non GestureDetector: così la
    // pressione lunga non finisce nell'arena dei gesti contro altri
    // riconoscitori. HitTestBehavior.opaque per ricevere il tocco su tutta
    // l'area del pulsante, non solo sui pixel dell'icona.
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _startHold(),
      onPointerUp: (_) => _cancelHold(),
      onPointerCancel: (_) => _cancelHold(),
      child: Semantics(
        button: true,
        label: 'Esci dalla modalità bambino: tieni premuto 3 secondi',
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => _controller.value > 0
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: _controller.value,
                          strokeWidth: 3,
                          color: scheme.primary,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const Icon(Icons.arrow_back),
            ],
          ),
        ),
      ),
    );
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
    final l10n = AppLocalizations.of(context)!;
    final settings = ref
            .watch(agendaSettingsProvider(items.first.item.agendaId))
            .valueOrNull ??
        const ProfileSettings();
    final current = items[currentIndex];
    final next =
        currentIndex + 1 < items.length ? items[currentIndex + 1] : null;

    // 'remaining' (default): la striscia mostra cosa resta da fare e si
    // svuota al check-off — TEACCH: l'attività finita si toglie.
    // 'history': comportamento precedente, le completate si accumulano.
    final history = settings.timelineMode == 'history';
    final strip = history
        ? items.take(currentIndex).toList()
        : items.skip(currentIndex).toList();

    return Column(
      children: [
        if (strip.isNotEmpty)
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: strip.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final row = strip[i];
                final isCurrent = !history && i == 0;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: history ? 0.5 : (isCurrent ? 1.0 : 0.6),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PictogramThumb(
                        type: row.activity.pictogramType,
                        pictogramRef: row.activity.pictogramRef,
                        size: isCurrent ? 52 : 44,
                      ),
                      if (history)
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                    ],
                  ),
                );
              },
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
                  Text(l10n.playerAfter,
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
    final l10n = AppLocalizations.of(context)!;
    final current = items[currentIndex];
    final next =
        currentIndex + 1 < items.length ? items[currentIndex + 1] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Adesso/Dopo" invece di "Prima/Poi": deitticamente ancorato
            // al presente del bambino, niente etichetta che "migra".
            Text(l10n.playerNow,
              style: Theme.of(context).textTheme.headlineSmall),
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
                Text(l10n.playerAfter.trim(),
                  style: Theme.of(context).textTheme.headlineSmall),
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
    final l10n = AppLocalizations.of(context)!;
    final settings =
        ref.watch(agendaSettingsProvider(row.item.agendaId)).valueOrNull ??
            const ProfileSettings();
    final size = (compact ? 140.0 : 200.0) * settings.cardScale;
    final timer = row.item.timerSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (!settings.tts) return;
            _speak(context, ref, row.activity);
          },
          child: PictogramThumb(
            type: row.activity.pictogramType,
            pictogramRef: row.activity.pictogramRef,
            size: size,
          ),
        ),
        const SizedBox(height: 16),
        Text(row.activity.label,
            style: Theme.of(context).textTheme.headlineMedium),
        if (settings.showTimes &&
            (row.item.startTime != null || row.item.endTime != null)) ...[
          const SizedBox(height: 4),
          Text(_formatTimes(l10n, row.item.startTime, row.item.endTime),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
        if (settings.showBadges) ...[
          _BadgeRow(item: row.item),
        ],
        const SizedBox(height: 16),
        if (timer != null) ...[
          settings.timerStyle == 'circular'
              ? _TimerRing(key: ValueKey(row.item.id), seconds: timer)
              : _TimerBar(key: ValueKey(row.item.id), seconds: timer),
          const SizedBox(height: 16),
        ],
        _DoneButton(
          key: ValueKey('done-${row.item.id}'),
          width: compact ? 140 : 200,
          onCompleted: () {
            if (settings.sounds) {
              unawaited(SystemSound.play(SystemSoundType.click));
            }
            ref.read(agendaRepoProvider).completeItem(row.item.id);
          },
        ),
      ],
    );
  }
}

String _formatTimes(AppLocalizations l10n, String? start, String? end) =>
    switch ((start, end)) {
      (null, null) => '',
      (null, final endTime) => l10n.playerEndOnly(endTime!),
      (final startTime, final endTime) =>
        l10n.playerTimeRange(startTime!, endTime!),
    };

/// Voce registrata dall'adulto se c'è, altrimenti sintesi vocale.
void _speak(BuildContext context, WidgetRef ref, Activity activity) {
  ref.read(activitySpeakerProvider).speak(
        text: activity.ttsText ?? activity.label,
        audioAssetId: activity.audioAssetId,
        locale: ttsLocaleFor(Localizations.localeOf(context).languageCode),
      );
}

/// Tabella gettoni: un gettone per attività, si riempie a ogni "Fatto";
/// in fondo il premio, sempre visibile come motivazione.
class _TokenBoard extends ConsumerWidget {
  const _TokenBoard(
      {required this.total, required this.earned, required this.reward});
  final int total;
  final int earned;
  final Activity reward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    // Oltre 10 gettoni si stringono, per restare su una riga anche su phone.
    final size = total > 10 ? 22.0 : 30.0;
    return Semantics(
      label: l10n.playerTokens(earned, total),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < total; i++)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        i < earned ? Icons.star_rounded : Icons.star_outline_rounded,
                        key: ValueKey(i < earned),
                        size: size,
                        color: i < earned
                            ? Colors.amber.shade600
                            : scheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: scheme.outline),
            const SizedBox(width: 8),
            PictogramThumb(
              type: reward.pictogramType,
              pictogramRef: reward.pictogramRef,
              size: 44,
            ),
          ],
        ),
      ),
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

/// Barra che si RIEMPIE col passare del tempo (feedback pilota: il
/// riempimento è percepito come progresso verso il "fatto", coerente
/// col pulsante verde). Default; l'anello resta come opzione.
class _TimerBar extends StatefulWidget {
  const _TimerBar({super.key, required this.seconds});
  final int seconds;

  @override
  State<_TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<_TimerBar>
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
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 220,
          height: 16,
          child: LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(scheme.tertiary),
          ),
        ),
      ),
    );
  }
}

/// Pulsante Fatto: al tap diventa verde con check pieno, breve pausa di
/// rinforzo, poi completa davvero. Non sovrastimolante: solo colore,
/// niente animazioni complesse.
class _DoneButton extends StatefulWidget {
  const _DoneButton(
      {super.key, required this.width, required this.onCompleted});
  final double width;
  final VoidCallback onCompleted;

  @override
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton> {
  bool _pressed = false;

  Future<void> _handleTap() async {
    if (_pressed) return;
    setState(() => _pressed = true);
    //HapticFeedback.mediumImpact();
    unawaited(HapticFeedback.mediumImpact());
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: Size(widget.width, K.childMinTouchTarget),
        textStyle: const TextStyle(fontSize: 20),
        backgroundColor: _pressed ? Colors.green.shade600 : null,
      ),
      icon: Icon(_pressed ? Icons.check_circle : Icons.check, size: 28),
      label: Text(_pressed ? l10n.playerDoneExclamation : l10n.playerDone),
      onPressed: _handleTap,
    );
  }
}

/// Dove/con chi sotto la card corrente: max 2 chip discreti, visibili
/// solo se showBadges attivo — chi non li usa non vede nulla.
class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.item});
  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    final place = ItemBadge.fromJsonString(item.placeJson);
    final companion = ItemBadge.fromJsonString(item.companionJson);
    if (place == null && companion == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (place != null) _badge(context, Icons.place_outlined, place),
          if (place != null && companion != null) const SizedBox(width: 12),
          if (companion != null)
            _badge(context, Icons.person_outline, companion),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, IconData icon, ItemBadge badge) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge.ref != null
              ? PictogramThumb(
                  type: badge.type == 'photo'
                      ? PictogramType.photo
                      : PictogramType.arasaac,
                  pictogramRef: badge.ref!,
                  size: 28,
                )
              : Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(badge.label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Fine agenda: rinforzo visivo semplice, non sovrastimolante.
/// Con un premio impostato mostra il premio (tocca per sentirlo).
class _EndView extends ConsumerWidget {
  const _EndView({required this.agendaId, this.reward});
  final String agendaId;
  final Activity? reward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reward = this.reward;
    final settings = ref.watch(agendaSettingsProvider(agendaId)).valueOrNull ??
        const ProfileSettings();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reward == null)
            Icon(Icons.star_rounded, size: 140, color: Colors.amber.shade400)
          else ...[
            Text(l10n.playerRewardEarned,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: settings.tts ? () => _speak(context, ref, reward) : null,
              child: PictogramThumb(
                type: reward.pictogramType,
                pictogramRef: reward.pictogramRef,
                size: 180 * settings.cardScale,
              ),
            ),
            const SizedBox(height: 8),
            Text(reward.label,
                style: Theme.of(context).textTheme.headlineMedium),
          ],
          const SizedBox(height: 16),
            Text(l10n.playerFinished,
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 32),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
                minimumSize: const Size(200, K.childMinTouchTarget)),
            onPressed: () =>
                ref.read(agendaRepoProvider).resetCompletions(agendaId),
            child: Text(l10n.playerRestart,
              style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
