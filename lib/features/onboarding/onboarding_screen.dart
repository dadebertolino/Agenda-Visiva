import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_service.dart';

/// Introduzione al primo avvio. Quattro schermate: cos'è, come funziona,
/// dove sono i dati, e come si esce dalla modalità bambino (il gate adulto —
/// il punto che più spesso blocca chi usa l'app la prima volta).
///
/// Al termine (o su "Salta") segna l'onboarding come visto e invalida
/// [onboardingDoneProvider]: il root dell'app mostra la Home.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.calendar_view_day_rounded,
      title: 'Crea agende visive',
      body: 'Accompagna la giornata del bambino con immagini chiare, '
          'una attività dopo l\'altra: meno ansia nei passaggi, più autonomia.',
    ),
    _OnboardingPage(
      icon: Icons.route_rounded,
      title: 'Come funziona',
      body: 'Tre passi semplici per iniziare.',
      steps: [
        _Step(Icons.child_care_rounded, 'Crea un profilo',
            'Un bambino, un profilo. Basta il nome.'),
        _Step(Icons.add_photo_alternate_rounded, 'Aggiungi le attività',
            'Scegli i pittogrammi ARASAAC o usa le tue foto.'),
        _Step(Icons.play_circle_fill_rounded, 'Passa alla modalità bambino',
            'Schermo grande, una cosa alla volta, spunta "Fatto".'),
      ],
    ),
    _OnboardingPage(
      icon: Icons.phonelink_lock_rounded,
      title: 'I dati restano qui',
      body: 'Nessun account, nessun server, nessun tracciamento. '
          'Nomi e foto dei bambini restano su questo dispositivo e non '
          'escono mai da qui.',
    ),
    _OnboardingPage(
      icon: Icons.back_hand_rounded,
      title: 'Uscire dalla modalità bambino',
      body: 'Durante l\'uso, per tornare all\'editor tieni premuta la '
          'freccia ← in alto a sinistra per 3 secondi.\n\n'
          'Un tocco normale non basta: così il bambino non esce da solo '
          'per sbaglio.',
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  Future<void> _finish() async {
    final service = await ref.read(onboardingServiceProvider.future);
    await service.markDone();
    ref.invalidate(onboardingDoneProvider);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: _isLast ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: _isLast ? null : _finish,
                  child: const Text('Salta'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _PageView(page: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _next,
                  child: Text(_isLast ? 'Inizia' : 'Avanti'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    this.steps = const [],
  });

  final IconData icon;
  final String title;
  final String body;
  final List<_Step> steps;
}

class _Step {
  const _Step(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 68, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          if (page.steps.isNotEmpty) ...[
            const SizedBox(height: 24),
            for (final step in page.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(step.icon,
                          color: scheme.onSecondaryContainer, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.title,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(step.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
