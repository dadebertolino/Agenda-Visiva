// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Agenda Visiva';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingStart => 'Inizia';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingCreateTitle => 'Crea agende visive';

  @override
  String get onboardingCreateBody =>
      'Accompagna la giornata del bambino con immagini chiare, una attività dopo l\'altra: meno ansia nei passaggi, più autonomia.';

  @override
  String get onboardingHowTitle => 'Come funziona';

  @override
  String get onboardingHowBody => 'Tre passi semplici per iniziare.';

  @override
  String get onboardingCreateProfile => 'Crea un profilo';

  @override
  String get onboardingCreateProfileBody =>
      'Un bambino, un profilo. Basta il nome.';

  @override
  String get onboardingAddActivities => 'Aggiungi le attività';

  @override
  String get onboardingAddActivitiesBody =>
      'Scegli i pittogrammi ARASAAC o usa le tue foto.';

  @override
  String get onboardingChildMode => 'Passa alla modalità bambino';

  @override
  String get onboardingChildModeBody =>
      'Schermo grande, una cosa alla volta, spunta \"Fatto\".';

  @override
  String get onboardingPrivacyTitle => 'I dati restano qui';

  @override
  String get onboardingPrivacyBody =>
      'Nessun account, nessun server, nessun tracciamento. Nomi e foto dei bambini restano su questo dispositivo e non escono mai da qui.';

  @override
  String get onboardingExitTitle => 'Uscire dalla modalità bambino';

  @override
  String get onboardingExitBody =>
      'Durante l\'uso, per tornare all\'editor tieni premuta la freccia ← in alto a sinistra per 3 secondi.\n\nUn tocco normale non basta: così il bambino non esce da solo per sbaglio.';
}
