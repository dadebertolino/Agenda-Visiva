import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/onboarding_service.dart';
import 'features/profiles/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AgendaVisivaApp()));
}

class AgendaVisivaApp extends StatelessWidget {
  const AgendaVisivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Visiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const _RootGate(),
    );
  }
}

/// Al primo avvio mostra l'onboarding; poi la Home. In caso di errore di
/// lettura del marker si apre comunque la Home (fail-open: l'onboarding non
/// deve mai bloccare l'accesso all'app).
class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(onboardingDoneProvider);
    return done.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const HomeScreen(),
      data: (isDone) => isDone ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
