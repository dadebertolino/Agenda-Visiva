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
