import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Persistenza "onboarding visto" senza nuove dipendenze e senza toccare
/// lo schema drift: un file marker nella documents dir (privato all'app,
/// mai trasmesso). Il nome porta la versione: bumpandola si può ri-mostrare
/// l'onboarding dopo un redesign importante.
class OnboardingService {
  OnboardingService(this._docsDir);

  final Directory _docsDir;

  static const _markerName = '.onboarding_v1_done';

  File get _marker => File('${_docsDir.path}/$_markerName');

  Future<bool> isDone() => _marker.exists();

  Future<void> markDone() async {
    if (!await _marker.exists()) {
      await _marker.create(recursive: true);
    }
  }

  /// Solo per debug/test: permette di rivedere l'introduzione.
  Future<void> reset() async {
    if (await _marker.exists()) await _marker.delete();
  }
}

final onboardingServiceProvider = FutureProvider<OnboardingService>((ref) async {
  final dir = await ref.watch(documentsDirProvider.future);
  return OnboardingService(dir);
});

/// true = onboarding già visto. Il root dell'app decide cosa mostrare.
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final service = await ref.watch(onboardingServiceProvider.future);
  return service.isDone();
});
