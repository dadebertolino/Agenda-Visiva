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

  /// No description provided for @builderItemOptions.
  ///
  /// In it, this message translates to:
  /// **'Opzioni attività'**
  String get builderItemOptions;

  /// No description provided for @builderTimer.
  ///
  /// In it, this message translates to:
  /// **'Timer visivo'**
  String get builderTimer;

  /// No description provided for @builderTimes.
  ///
  /// In it, this message translates to:
  /// **'Orario inizio e fine'**
  String get builderTimes;

  /// No description provided for @builderBadges.
  ///
  /// In it, this message translates to:
  /// **'Dove e con chi'**
  String get builderBadges;

  /// No description provided for @builderRemove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dall\'agenda'**
  String get builderRemove;

  /// No description provided for @builderStartTimeHelp.
  ///
  /// In it, this message translates to:
  /// **'Orario di inizio (Annulla = nessuno)'**
  String get builderStartTimeHelp;

  /// No description provided for @builderEndTimeHelp.
  ///
  /// In it, this message translates to:
  /// **'Orario di fine (Annulla = nessuno)'**
  String get builderEndTimeHelp;

  /// No description provided for @builderWhereHint.
  ///
  /// In it, this message translates to:
  /// **'Dove (es. Palestra)'**
  String get builderWhereHint;

  /// No description provided for @builderWithWhoHint.
  ///
  /// In it, this message translates to:
  /// **'Con chi (es. Maria)'**
  String get builderWithWhoHint;

  /// No description provided for @builderChoosePictogram.
  ///
  /// In it, this message translates to:
  /// **'Scegli pittogramma'**
  String get builderChoosePictogram;

  /// No description provided for @builderCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get builderCancel;

  /// No description provided for @builderSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get builderSave;

  /// No description provided for @builderTimerTitle.
  ///
  /// In it, this message translates to:
  /// **'Timer visivo'**
  String get builderTimerTitle;

  /// No description provided for @builderNoTimer.
  ///
  /// In it, this message translates to:
  /// **'Nessuno'**
  String get builderNoTimer;

  /// No description provided for @builderMinutes.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1 {1 minuto} other {{count} minuti}}'**
  String builderMinutes(num count);

  /// No description provided for @builderTimerSummary.
  ///
  /// In it, this message translates to:
  /// **'Timer: {minutes} min'**
  String builderTimerSummary(num minutes);

  /// No description provided for @builderEndOnly.
  ///
  /// In it, this message translates to:
  /// **'– {end}'**
  String builderEndOnly(String end);

  /// No description provided for @builderTimeRange.
  ///
  /// In it, this message translates to:
  /// **'{start} – {end}'**
  String builderTimeRange(String start, String end);

  /// No description provided for @playerNeeds.
  ///
  /// In it, this message translates to:
  /// **'I miei bisogni'**
  String get playerNeeds;

  /// No description provided for @playerExitHint.
  ///
  /// In it, this message translates to:
  /// **'Per uscire, tieni premuta la freccia per 3 secondi'**
  String get playerExitHint;

  /// No description provided for @playerEmpty.
  ///
  /// In it, this message translates to:
  /// **'Agenda vuota'**
  String get playerEmpty;

  /// No description provided for @playerAfter.
  ///
  /// In it, this message translates to:
  /// **'Dopo: '**
  String get playerAfter;

  /// No description provided for @playerNow.
  ///
  /// In it, this message translates to:
  /// **'Adesso'**
  String get playerNow;

  /// No description provided for @playerDone.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get playerDone;

  /// No description provided for @playerDoneExclamation.
  ///
  /// In it, this message translates to:
  /// **'Fatto!'**
  String get playerDoneExclamation;

  /// No description provided for @playerFinished.
  ///
  /// In it, this message translates to:
  /// **'Hai finito!'**
  String get playerFinished;

  /// No description provided for @playerRestart.
  ///
  /// In it, this message translates to:
  /// **'Ricomincia'**
  String get playerRestart;

  /// No description provided for @playerEndOnly.
  ///
  /// In it, this message translates to:
  /// **'– {end}'**
  String playerEndOnly(String end);

  /// No description provided for @playerTimeRange.
  ///
  /// In it, this message translates to:
  /// **'{start} – {end}'**
  String playerTimeRange(String start, String end);

  /// No description provided for @needsBoardTitle.
  ///
  /// In it, this message translates to:
  /// **'I miei bisogni'**
  String get needsBoardTitle;

  /// No description provided for @needsBoardEmpty.
  ///
  /// In it, this message translates to:
  /// **'Chiedi a un adulto di aggiungere i bisogni dalla matita nella schermata delle agende.'**
  String get needsBoardEmpty;

  /// No description provided for @needsBoardEditTitle.
  ///
  /// In it, this message translates to:
  /// **'I miei bisogni — modifica'**
  String get needsBoardEditTitle;

  /// No description provided for @needsBoardEmptyAdult.
  ///
  /// In it, this message translates to:
  /// **'La tavola è vuota'**
  String get needsBoardEmptyAdult;

  /// No description provided for @needsBoardSeed.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi bisogni di base'**
  String get needsBoardSeed;

  /// No description provided for @needsBoardAdvice.
  ///
  /// In it, this message translates to:
  /// **'Consiglio: tieni la tavola corta (6-8 bisogni). Poche scelte chiare aiutano più di tante.'**
  String get needsBoardAdvice;

  /// No description provided for @needsBoardAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get needsBoardAdd;

  /// No description provided for @needsBoardWord.
  ///
  /// In it, this message translates to:
  /// **'Parola da pronunciare'**
  String get needsBoardWord;

  /// No description provided for @pickerTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli un pittogramma'**
  String get pickerTitle;

  /// No description provided for @pickerArasaac.
  ///
  /// In it, this message translates to:
  /// **'ARASAAC'**
  String get pickerArasaac;

  /// No description provided for @pickerPhoto.
  ///
  /// In it, this message translates to:
  /// **'Foto'**
  String get pickerPhoto;

  /// No description provided for @pickerBuiltin.
  ///
  /// In it, this message translates to:
  /// **'Base'**
  String get pickerBuiltin;

  /// No description provided for @pickerSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca (es. colazione, cerchio, bagno)'**
  String get pickerSearchHint;

  /// No description provided for @pickerOfflineError.
  ///
  /// In it, this message translates to:
  /// **'Ricerca non riuscita. Sei offline? Le ricerche già fatte funzionano anche senza rete.'**
  String get pickerOfflineError;

  /// No description provided for @pickerSearchPrompt.
  ///
  /// In it, this message translates to:
  /// **'Scrivi per cercare tra migliaia di pittogrammi'**
  String get pickerSearchPrompt;

  /// No description provided for @pickerNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato'**
  String get pickerNoResults;

  /// No description provided for @pickerGallery.
  ///
  /// In it, this message translates to:
  /// **'Scegli dalla galleria'**
  String get pickerGallery;

  /// No description provided for @pickerCamera.
  ///
  /// In it, this message translates to:
  /// **'Scatta una foto'**
  String get pickerCamera;

  /// No description provided for @pickerPhotoPrivacy.
  ///
  /// In it, this message translates to:
  /// **'La foto resta solo su questo dispositivo. Posizione e metadati (EXIF) vengono rimossi automaticamente.'**
  String get pickerPhotoPrivacy;

  /// No description provided for @pickerCameraError.
  ///
  /// In it, this message translates to:
  /// **'Fotocamera non disponibile su questo dispositivo'**
  String get pickerCameraError;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni — {name}'**
  String settingsTitle(String name);

  /// No description provided for @settingsChildMode.
  ///
  /// In it, this message translates to:
  /// **'Modalità bambino'**
  String get settingsChildMode;

  /// No description provided for @settingsVoice.
  ///
  /// In it, this message translates to:
  /// **'Voce (leggi le attività)'**
  String get settingsVoice;

  /// No description provided for @settingsVoiceSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tocca il pittogramma per ascoltare'**
  String get settingsVoiceSubtitle;

  /// No description provided for @settingsSounds.
  ///
  /// In it, this message translates to:
  /// **'Suoni di conferma'**
  String get settingsSounds;

  /// No description provided for @settingsContrast.
  ///
  /// In it, this message translates to:
  /// **'Alto contrasto'**
  String get settingsContrast;

  /// No description provided for @settingsCardSize.
  ///
  /// In it, this message translates to:
  /// **'Dimensione pittogrammi'**
  String get settingsCardSize;

  /// No description provided for @settingsTimer.
  ///
  /// In it, this message translates to:
  /// **'Timer visivo'**
  String get settingsTimer;

  /// No description provided for @settingsTimerSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Barra che si riempie o anello che si svuota'**
  String get settingsTimerSubtitle;

  /// No description provided for @settingsBar.
  ///
  /// In it, this message translates to:
  /// **'Barra'**
  String get settingsBar;

  /// No description provided for @settingsRing.
  ///
  /// In it, this message translates to:
  /// **'Anello'**
  String get settingsRing;

  /// No description provided for @settingsTimeline.
  ///
  /// In it, this message translates to:
  /// **'Linea attività'**
  String get settingsTimeline;

  /// No description provided for @settingsTimelineSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Mostra cosa resta da fare o cosa è già fatto'**
  String get settingsTimelineSubtitle;

  /// No description provided for @settingsRemaining.
  ///
  /// In it, this message translates to:
  /// **'Da fare'**
  String get settingsRemaining;

  /// No description provided for @settingsHistory.
  ///
  /// In it, this message translates to:
  /// **'Fatte'**
  String get settingsHistory;

  /// No description provided for @settingsShowTimes.
  ///
  /// In it, this message translates to:
  /// **'Mostra orari'**
  String get settingsShowTimes;

  /// No description provided for @settingsShowTimesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Orario di inizio e fine sotto l\'attività, se impostati'**
  String get settingsShowTimesSubtitle;

  /// No description provided for @settingsShowBadges.
  ///
  /// In it, this message translates to:
  /// **'Mostra dove e con chi'**
  String get settingsShowBadges;

  /// No description provided for @settingsShowBadgesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Luogo e persona sotto l\'attività, se impostati'**
  String get settingsShowBadgesSubtitle;

  /// No description provided for @settingsInfo.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get settingsInfo;

  /// No description provided for @settingsPrivacy.
  ///
  /// In it, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tutti i dati restano su questo dispositivo'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In it, this message translates to:
  /// **'Agenda Visiva funziona completamente offline.\n\nNomi, foto e agende non lasciano mai questo dispositivo: nessun account, nessun server, nessun tracciamento, nessuna pubblicità.\n\nLe foto importate vengono ridimensionate e ripulite dai metadati (inclusa la posizione GPS).\n\nLa condivisione di un\'agenda (.agviz o PDF) avviene solo quando la avvii tu, con gli strumenti del tuo dispositivo. I file .agviz non contengono mai il nome del bambino.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsCredits.
  ///
  /// In it, this message translates to:
  /// **'Crediti pittogrammi'**
  String get settingsCredits;

  /// No description provided for @settingsCreditsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'ARASAAC'**
  String get settingsCreditsSubtitle;

  /// No description provided for @settingsCreditsBody.
  ///
  /// In it, this message translates to:
  /// **'{attribution}.\n\nI pittogrammi ARASAAC sono utilizzabili solo per scopi non commerciali e con questa attribuzione.'**
  String settingsCreditsBody(String attribution);

  /// No description provided for @settingsLicense.
  ///
  /// In it, this message translates to:
  /// **'Licenza e codice sorgente'**
  String get settingsLicense;

  /// No description provided for @settingsLicenseSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Codice pubblico su GitHub — PolyForm Noncommercial 1.0.0'**
  String get settingsLicenseSubtitle;

  /// No description provided for @settingsSourceTitle.
  ///
  /// In it, this message translates to:
  /// **'Codice sorgente pubblico'**
  String get settingsSourceTitle;

  /// No description provided for @settingsSourceBody.
  ///
  /// In it, this message translates to:
  /// **'Il codice di Agenda Visiva è pubblico, consultabile e gratuito per sempre. Chiunque può verificare come funziona e che i dati non lasciano mai il dispositivo.\n\nL\'uso commerciale è vietato (licenza PolyForm Noncommercial 1.0.0).'**
  String get settingsSourceBody;

  /// No description provided for @settingsClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get settingsClose;

  /// No description provided for @settingsOpenGithub.
  ///
  /// In it, this message translates to:
  /// **'Apri GitHub'**
  String get settingsOpenGithub;

  /// No description provided for @settingsAuthor.
  ///
  /// In it, this message translates to:
  /// **'Autore'**
  String get settingsAuthor;

  /// No description provided for @settingsAuthorBody.
  ///
  /// In it, this message translates to:
  /// **'Made by Prof. Davide Bertolino\nPer contatti: info@davidebertolino.it'**
  String get settingsAuthorBody;

  /// No description provided for @settingsVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione'**
  String get settingsVersion;
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
