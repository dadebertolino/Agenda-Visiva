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

  @override
  String get homeCreateFirstProfile =>
      'Create the first profile to get started';

  @override
  String get homeNewProfile => 'New profile';

  @override
  String get homeProfileOptions => 'Profile options';

  @override
  String homeAgendasOf(Object name) {
    return '$name\'s schedules';
  }

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeImportAgenda => 'Import schedule (.agviz)';

  @override
  String get homeNeeds => 'My needs';

  @override
  String get homeNeedsSubtitle => 'Tap an image to hear the word';

  @override
  String get homeEditBoard => 'Edit board';

  @override
  String get homeNoAgenda => 'No schedules. Create one with +';

  @override
  String get homeStartChild => 'Start for child';

  @override
  String get homeNewAgenda => 'New schedule';

  @override
  String get agendaTypeDaily => 'Day';

  @override
  String get agendaTypeFirstThen => 'First–Then';

  @override
  String get agendaTypeSequence => 'Sequence';

  @override
  String get homeNewProfileTitle => 'New profile';

  @override
  String get homeProfileNameLabel => 'Name or nickname';

  @override
  String get homeProfileNameHelper =>
      'Recommended: first name only, no surname.\nStays on this device.';

  @override
  String get homeCreate => 'Create';

  @override
  String get homeRename => 'Rename';

  @override
  String get homeDelete => 'Delete';

  @override
  String get homeRenameProfileTitle => 'Rename profile';

  @override
  String get homeSave => 'Save';

  @override
  String homeDeleteProfileQuestion(String name) {
    return 'Delete $name?';
  }

  @override
  String get homeDeleteProfileBody =>
      'Its schedules will no longer be visible.';

  @override
  String get homeCancel => 'Cancel';

  @override
  String get homeShareAgenda => 'Share (.agviz)';

  @override
  String get homeSharePhotosWarning =>
      'If it contains photos, share only with trusted people';

  @override
  String get homeDeleteAgenda => 'Delete';

  @override
  String homeShareFailed(String error) {
    return 'Sharing failed: $error';
  }

  @override
  String get homeImportSuccess => 'Schedule imported';

  @override
  String homeImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get homeNewAgendaTitle => 'New schedule';

  @override
  String get homeAgendaTitleLabel => 'Title';

  @override
  String get homeAgendaTitleHint => 'E.g. Morning routine';

  @override
  String homeDeleteAgendaQuestion(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String homeShareText(String title) {
    return 'Schedule \"$title\" — open with Visual Schedule';
  }
}
