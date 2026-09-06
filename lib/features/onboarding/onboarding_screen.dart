import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
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

  List<_OnboardingPage> _pages(AppLocalizations l10n) => [
    _OnboardingPage(
      icon: Icons.calendar_view_day_rounded,
      title: l10n.onboardingCreateTitle,
      body: l10n.onboardingCreateBody,
    ),
    _OnboardingPage(
      icon: Icons.route_rounded,
      title: l10n.onboardingHowTitle,
      body: l10n.onboardingHowBody,
      steps: [
        _Step(Icons.child_care_rounded, l10n.onboardingCreateProfile,
            l10n.onboardingCreateProfileBody),
        _Step(Icons.add_photo_alternate_rounded, l10n.onboardingAddActivities,
            l10n.onboardingAddActivitiesBody),
        _Step(Icons.play_circle_fill_rounded, l10n.onboardingChildMode,
            l10n.onboardingChildModeBody),
      ],
    ),
    _OnboardingPage(
      icon: Icons.phonelink_lock_rounded,
      title: l10n.onboardingPrivacyTitle,
      body: l10n.onboardingPrivacyBody,
    ),
    _OnboardingPage(
      icon: Icons.back_hand_rounded,
      title: l10n.onboardingExitTitle,
      body: l10n.onboardingExitBody,
    ),
  ];

  bool get _isLast => _page == 3;

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
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages(l10n);

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
                  child: Text(l10n.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: pages.length,
                itemBuilder: (context, i) => _PageView(page: pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
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
                    child: Text(
                      _isLast ? l10n.onboardingStart : l10n.onboardingNext),
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
