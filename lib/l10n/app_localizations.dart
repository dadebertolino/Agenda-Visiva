import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'Agenda Visiva'**
  String get appTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get onboardingSkip;

  /// No description provided for @onboardingStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get onboardingStart;

  /// No description provided for @onboardingNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get onboardingNext;

  /// No description provided for @onboardingCreateTitle.
  ///
  /// In it, this message translates to:
  /// **'Crea agende visive'**
  String get onboardingCreateTitle;

  /// No description provided for @onboardingCreateBody.
  ///
  /// In it, this message translates to:
  /// **'Accompagna la giornata del bambino con immagini chiare, una attività dopo l\'altra: meno ansia nei passaggi, più autonomia.'**
  String get onboardingCreateBody;

  /// No description provided for @onboardingHowTitle.
  ///
  /// In it, this message translates to:
  /// **'Come funziona'**
  String get onboardingHowTitle;

  /// No description provided for @onboardingHowBody.
  ///
  /// In it, this message translates to:
  /// **'Tre passi semplici per iniziare.'**
  String get onboardingHowBody;

  /// No description provided for @onboardingCreateProfile.
  ///
  /// In it, this message translates to:
  /// **'Crea un profilo'**
  String get onboardingCreateProfile;

  /// No description provided for @onboardingCreateProfileBody.
  ///
  /// In it, this message translates to:
  /// **'Un bambino, un profilo. Basta il nome.'**
  String get onboardingCreateProfileBody;

  /// No description provided for @onboardingAddActivities.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi le attività'**
  String get onboardingAddActivities;

  /// No description provided for @onboardingAddActivitiesBody.
  ///
  /// In it, this message translates to:
  /// **'Scegli i pittogrammi ARASAAC o usa le tue foto.'**
  String get onboardingAddActivitiesBody;

  /// No description provided for @onboardingChildMode.
  ///
  /// In it, this message translates to:
  /// **'Passa alla modalità bambino'**
  String get onboardingChildMode;

  /// No description provided for @onboardingChildModeBody.
  ///
  /// In it, this message translates to:
  /// **'Schermo grande, una cosa alla volta, spunta \"Fatto\".'**
  String get onboardingChildModeBody;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In it, this message translates to:
  /// **'I dati restano qui'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyBody.
  ///
  /// In it, this message translates to:
  /// **'Nessun account, nessun server, nessun tracciamento. Nomi e foto dei bambini restano su questo dispositivo e non escono mai da qui.'**
  String get onboardingPrivacyBody;

  /// No description provided for @onboardingExitTitle.
  ///
  /// In it, this message translates to:
  /// **'Uscire dalla modalità bambino'**
  String get onboardingExitTitle;

  /// No description provided for @onboardingExitBody.
  ///
  /// In it, this message translates to:
  /// **'Durante l\'uso, per tornare all\'editor tieni premuta la freccia ← in alto a sinistra per 3 secondi.\n\nUn tocco normale non basta: così il bambino non esce da solo per sbaglio.'**
  String get onboardingExitBody;

  /// No description provided for @homeCreateFirstProfile.
  ///
  /// In it, this message translates to:
  /// **'Crea il primo profilo per iniziare'**
  String get homeCreateFirstProfile;

  /// No description provided for @homeNewProfile.
  ///
  /// In it, this message translates to:
  /// **'Nuovo profilo'**
  String get homeNewProfile;

  /// No description provided for @homeProfileOptions.
  ///
  /// In it, this message translates to:
  /// **'Opzioni profilo'**
  String get homeProfileOptions;

  /// No description provided for @homeAgendasOf.
  ///
  /// In it, this message translates to:
  /// **'Agende di {name}'**
  String homeAgendasOf(Object name);

  /// No description provided for @homeSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get homeSettings;

  /// No description provided for @homeImportAgenda.
  ///
  /// In it, this message translates to:
  /// **'Importa agenda (.agviz)'**
  String get homeImportAgenda;

  /// No description provided for @homeNeeds.
  ///
  /// In it, this message translates to:
  /// **'I miei bisogni'**
  String get homeNeeds;

  /// No description provided for @homeNeedsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tocca un\'immagine, la voce parla'**
  String get homeNeedsSubtitle;

  /// No description provided for @homeEditBoard.
  ///
  /// In it, this message translates to:
  /// **'Modifica la tavola'**
  String get homeEditBoard;

  /// No description provided for @homeNoAgenda.
  ///
  /// In it, this message translates to:
  /// **'Nessuna agenda. Creane una con +'**
  String get homeNoAgenda;

  /// No description provided for @homeStartChild.
  ///
  /// In it, this message translates to:
  /// **'Avvia per il bambino'**
  String get homeStartChild;

  /// No description provided for @homeNewAgenda.
  ///
  /// In it, this message translates to:
  /// **'Nuova agenda'**
  String get homeNewAgenda;

  /// No description provided for @agendaTypeDaily.
  ///
  /// In it, this message translates to:
  /// **'Giornata'**
  String get agendaTypeDaily;

  /// No description provided for @agendaTypeFirstThen.
  ///
  /// In it, this message translates to:
  /// **'Prima–Poi'**
  String get agendaTypeFirstThen;

  /// No description provided for @agendaTypeSequence.
  ///
  /// In it, this message translates to:
  /// **'Sequenza'**
  String get agendaTypeSequence;

  /// No description provided for @homeNewProfileTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo profilo'**
  String get homeNewProfileTitle;

  /// No description provided for @homeProfileNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome o soprannome'**
  String get homeProfileNameLabel;

  /// No description provided for @homeProfileNameHelper.
  ///
  /// In it, this message translates to:
  /// **'Consigliato: solo il nome, niente cognome.\nResta solo su questo dispositivo.'**
  String get homeProfileNameHelper;

  /// No description provided for @homeCreate.
  ///
  /// In it, this message translates to:
  /// **'Crea'**
  String get homeCreate;

  /// No description provided for @homeRename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get homeRename;

  /// No description provided for @homeDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get homeDelete;

  /// No description provided for @homeRenameProfileTitle.
  ///
  /// In it, this message translates to:
  /// **'Rinomina profilo'**
  String get homeRenameProfileTitle;

  /// No description provided for @homeSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get homeSave;

  /// No description provided for @homeDeleteProfileQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare {name}?'**
  String homeDeleteProfileQuestion(String name);

  /// No description provided for @homeDeleteProfileBody.
  ///
  /// In it, this message translates to:
  /// **'Le sue agende non saranno più visibili.'**
  String get homeDeleteProfileBody;

  /// No description provided for @homeCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get homeCancel;

  /// No description provided for @homeShareAgenda.
  ///
  /// In it, this message translates to:
  /// **'Condividi (.agviz)'**
  String get homeShareAgenda;

  /// No description provided for @homeSharePhotosWarning.
  ///
  /// In it, this message translates to:
  /// **'Se contiene foto, condividi solo con persone fidate'**
  String get homeSharePhotosWarning;

  /// No description provided for @homeDeleteAgenda.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get homeDeleteAgenda;

  /// No description provided for @homeShareFailed.
  ///
  /// In it, this message translates to:
  /// **'Condivisione non riuscita: {error}'**
  String homeShareFailed(String error);

  /// No description provided for @homeImportSuccess.
  ///
  /// In it, this message translates to:
  /// **'Agenda importata'**
  String get homeImportSuccess;

  /// No description provided for @homeImportFailed.
  ///
  /// In it, this message translates to:
  /// **'Import non riuscito: {error}'**
  String homeImportFailed(String error);

  /// No description provided for @homeNewAgendaTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuova agenda'**
  String get homeNewAgendaTitle;

  /// No description provided for @homeAgendaTitleLabel.
  ///
  /// In it, this message translates to:
  /// **'Titolo'**
  String get homeAgendaTitleLabel;

  /// No description provided for @homeAgendaTitleHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Routine mattina'**
  String get homeAgendaTitleHint;

  /// No description provided for @homeDeleteAgendaQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare \"{title}\"?'**
  String homeDeleteAgendaQuestion(String title);

  /// No description provided for @homeShareText.
  ///
  /// In it, this message translates to:
  /// **'Agenda \"{title}\" — apribile con Agenda Visiva'**
  String homeShareText(String title);

  /// No description provided for @builderPrintPdf.
  ///
  /// In it, this message translates to:
  /// **'Stampa / PDF'**
  String get builderPrintPdf;

  /// No description provided for @builderPreview.
  ///
  /// In it, this message translates to:
  /// **'Anteprima come bambino'**
  String get builderPreview;

  /// No description provided for @builderEmpty.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi la prima attività'**
  String get builderEmpty;

  /// No description provided for @builderAddActivity.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi attività'**
  String get builderAddActivity;

  /// No description provided for @builderFormat.
  ///
  /// In it, this message translates to:
  /// **'Formato'**
  String get builderFormat;

  /// No description provided for @builderGrid.
  ///
  /// In it, this message translates to:
  /// **'Griglia'**
  String get builderGrid;

  /// No description provided for @builderList.
  ///
  /// In it, this message translates to:
  /// **'Elenco'**
  String get builderList;

  /// No description provided for @builderPictogramsPerPage.
  ///
  /// In it, this message translates to:
  /// **'Pittogrammi per pagina'**
  String get builderPictogramsPerPage;

  /// No description provided for @builderPrint.
  ///
  /// In it, this message translates to:
  /// **'Stampa'**
  String get builderPrint;

  /// No description provided for @builderGridSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ottimizzato per ritaglio e laminazione'**
  String get builderGridSubtitle;

  /// No description provided for @builderListSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Elenco della giornata con orari e caselle'**
  String get builderListSubtitle;

  /// No description provided for @builderSharePdf.
  ///
  /// In it, this message translates to:
  /// **'Condividi PDF'**
  String get builderSharePdf;

  /// No description provided for @builderPreparingPdf.
  ///
  /// In it, this message translates to:
  /// **'Preparo il PDF…'**
  String get builderPreparingPdf;

  /// No description provided for @builderNeedActivity.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi almeno un\'attività prima di esportare'**
  String get builderNeedActivity;

  /// No description provided for @builderExportFailed.
  ///
  /// In it, this message translates to:
  /// **'Export non riuscito: {error}'**
  String builderExportFailed(String error);

  /// No description provided for @builderActivityName.
  ///
  /// In it, this message translates to:
  /// **'Nome attività'**
  String get builderActivityName;

  /// No description provided for @builderAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get builderAdd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
