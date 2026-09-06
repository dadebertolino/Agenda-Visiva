// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Visual Schedule';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingCreateTitle => 'Create visual schedules';

  @override
  String get onboardingCreateBody =>
      'Guide the child\'s day with clear images, one activity after another: less anxiety during transitions, more independence.';

  @override
  String get onboardingHowTitle => 'How it works';

  @override
  String get onboardingHowBody => 'Three simple steps to get started.';

  @override
  String get onboardingCreateProfile => 'Create a profile';

  @override
  String get onboardingCreateProfileBody =>
      'One child, one profile. Just the name.';

  @override
  String get onboardingAddActivities => 'Add activities';

  @override
  String get onboardingAddActivitiesBody =>
      'Choose ARASAAC pictograms or use your own photos.';

  @override
  String get onboardingChildMode => 'Switch to child mode';

  @override
  String get onboardingChildModeBody =>
      'Large screen, one thing at a time, tap \"Done\".';

  @override
  String get onboardingPrivacyTitle => 'Your data stays here';

  @override
  String get onboardingPrivacyBody =>
      'No account, no server, no tracking. Children\'s names and photos stay on this device and never leave it.';

  @override
  String get onboardingExitTitle => 'Exit child mode';

  @override
  String get onboardingExitBody =>
      'To return to the editor, press and hold the arrow ← in the top left for 3 seconds.\n\nA normal tap is not enough, so the child cannot exit by mistake.';
}
