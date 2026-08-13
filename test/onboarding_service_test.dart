import 'dart:io';

import 'package:agenda_visiva/features/onboarding/onboarding_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('onboarding_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('isDone parte da false, markDone lo rende true', () async {
    final service = OnboardingService(dir);
    expect(await service.isDone(), isFalse);

    await service.markDone();
    expect(await service.isDone(), isTrue);
  });

  test('markDone è idempotente', () async {
    final service = OnboardingService(dir);
    await service.markDone();
    await service.markDone();
    expect(await service.isDone(), isTrue);
  });

  test('reset riporta a non visto', () async {
    final service = OnboardingService(dir);
    await service.markDone();
    await service.reset();
    expect(await service.isDone(), isFalse);
  });
}
