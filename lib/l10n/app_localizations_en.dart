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

  @override
  String get builderPrintPdf => 'Print / PDF';

  @override
  String get builderPreview => 'Preview as child';

  @override
  String get builderEmpty => 'Add the first activity';

  @override
  String get builderAddActivity => 'Add activity';

  @override
  String get builderFormat => 'Format';

  @override
  String get builderGrid => 'Grid';

  @override
  String get builderList => 'List';

  @override
  String get builderPictogramsPerPage => 'Pictograms per page';

  @override
  String get builderPrint => 'Print';

  @override
  String get builderGridSubtitle => 'Optimized for cutting and laminating';

  @override
  String get builderListSubtitle => 'Daily list with times and checkboxes';

  @override
  String get builderSharePdf => 'Share PDF';

  @override
  String get builderPreparingPdf => 'Preparing PDF…';

  @override
  String get builderNeedActivity =>
      'Add at least one activity before exporting';

  @override
  String builderExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get builderActivityName => 'Activity name';

  @override
  String get builderAdd => 'Add';

  @override
  String get builderItemOptions => 'Activity options';

  @override
  String get builderTimer => 'Visual timer';

  @override
  String get builderTimes => 'Start and end time';

  @override
  String get builderBadges => 'Where and with whom';

  @override
  String get builderRemove => 'Remove from schedule';

  @override
  String get builderStartTimeHelp => 'Start time (Cancel = none)';

  @override
  String get builderEndTimeHelp => 'End time (Cancel = none)';

  @override
  String get builderWhereHint => 'Where (e.g. Gym)';

  @override
  String get builderWithWhoHint => 'With whom (e.g. Maria)';

  @override
  String get builderChoosePictogram => 'Choose pictogram';

  @override
  String get builderCancel => 'Cancel';

  @override
  String get builderSave => 'Save';

  @override
  String get builderTimerTitle => 'Visual timer';

  @override
  String get builderNoTimer => 'None';

  @override
  String builderMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String builderTimerSummary(num minutes) {
    return 'Timer: $minutes min';
  }

  @override
  String builderEndOnly(String end) {
    return '– $end';
  }

  @override
  String builderTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get playerNeeds => 'My needs';

  @override
  String get playerExitHint =>
      'To exit, press and hold the arrow for 3 seconds';

  @override
  String get playerEmpty => 'Empty schedule';

  @override
  String get playerAfter => 'Next: ';

  @override
  String get playerNow => 'Now';

  @override
  String get playerDone => 'Done';

  @override
  String get playerDoneExclamation => 'Done!';

  @override
  String get playerFinished => 'You\'re finished!';

  @override
  String get playerRestart => 'Start again';

  @override
  String playerEndOnly(String end) {
    return '– $end';
  }

  @override
  String playerTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get needsBoardTitle => 'My needs';

  @override
  String get needsBoardEmpty =>
      'Ask an adult to add needs using the pencil on the schedules screen.';

  @override
  String get needsBoardEditTitle => 'My needs — edit';

  @override
  String get needsBoardEmptyAdult => 'The board is empty';

  @override
  String get needsBoardSeed => 'Add basic needs';

  @override
  String get needsBoardAdvice =>
      'Tip: keep the board short (6-8 needs). A few clear choices work better than many.';

  @override
  String get needsBoardAdd => 'Add';

  @override
  String get needsBoardWord => 'Word to speak';

  @override
  String get pickerTitle => 'Choose a pictogram';

  @override
  String get pickerArasaac => 'ARASAAC';

  @override
  String get pickerPhoto => 'Photo';

  @override
  String get pickerBuiltin => 'Built-in';

  @override
  String get pickerSearchHint => 'Search (e.g. breakfast, circle, bathroom)';

  @override
  String get pickerOfflineError =>
      'Search failed. Are you offline? Previous searches still work offline.';

  @override
  String get pickerSearchPrompt => 'Search among thousands of pictograms';

  @override
  String get pickerNoResults => 'No results';

  @override
  String get pickerGallery => 'Choose from gallery';

  @override
  String get pickerCamera => 'Take a photo';

  @override
  String get pickerPhotoPrivacy =>
      'The photo stays on this device. Location and metadata (EXIF) are removed automatically.';

  @override
  String get pickerCameraError => 'Camera unavailable on this device';

  @override
  String settingsTitle(String name) {
    return 'Settings — $name';
  }

  @override
  String get settingsChildMode => 'Child mode';

  @override
  String get settingsVoice => 'Voice (read activities aloud)';

  @override
  String get settingsVoiceSubtitle => 'Tap the pictogram to listen';

  @override
  String get settingsSounds => 'Confirmation sounds';

  @override
  String get settingsContrast => 'High contrast';

  @override
  String get settingsCardSize => 'Pictogram size';

  @override
  String get settingsTimer => 'Visual timer';

  @override
  String get settingsTimerSubtitle => 'Bar filling up or ring emptying';

  @override
  String get settingsBar => 'Bar';

  @override
  String get settingsRing => 'Ring';

  @override
  String get settingsTimeline => 'Activity line';

  @override
  String get settingsTimelineSubtitle =>
      'Show what remains or what is completed';

  @override
  String get settingsRemaining => 'To do';

  @override
  String get settingsHistory => 'Done';

  @override
  String get settingsShowTimes => 'Show times';

  @override
  String get settingsShowTimesSubtitle =>
      'Start and end time below the activity, when set';

  @override
  String get settingsShowBadges => 'Show where and with whom';

  @override
  String get settingsShowBadgesSubtitle =>
      'Place and person below the activity, when set';

  @override
  String get settingsInfo => 'Information';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySubtitle => 'All data stays on this device';

  @override
  String get settingsPrivacyBody =>
      'Visual Schedule works completely offline.\n\nChildren\'s names, photos and schedules never leave this device: no account, no server, no tracking, no advertising.\n\nImported photos are resized and stripped of metadata (including GPS location).\n\nSharing a schedule (.agviz or PDF) happens only when you start it using your device\'s tools. .agviz files never contain the child\'s name.';

  @override
  String get settingsCredits => 'Pictogram credits';

  @override
  String get settingsCreditsSubtitle => 'ARASAAC';

  @override
  String settingsCreditsBody(String attribution) {
    return '$attribution.\n\nARASAAC pictograms may be used only for non-commercial purposes and with this attribution.';
  }

  @override
  String get settingsLicense => 'License and source code';

  @override
  String get settingsLicenseSubtitle =>
      'Public code on GitHub — PolyForm Noncommercial 1.0.0';

  @override
  String get settingsSourceTitle => 'Public source code';

  @override
  String get settingsSourceBody =>
      'The Visual Schedule code is public, available for inspection and free forever. Anyone can verify how it works and that data never leaves the device.\n\nCommercial use is prohibited (PolyForm Noncommercial 1.0.0 license).';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsOpenGithub => 'Open GitHub';

  @override
  String get settingsAuthor => 'Author';

  @override
  String get settingsAuthorBody =>
      'Made by Prof. Davide Bertolino\nContact: info@davidebertolino.it';

  @override
  String get settingsVersion => 'Version';
}
