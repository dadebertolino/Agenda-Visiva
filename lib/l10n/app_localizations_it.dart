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

  @override
  String get homeCreateFirstProfile => 'Crea il primo profilo per iniziare';

  @override
  String get homeNewProfile => 'Nuovo profilo';

  @override
  String get homeProfileOptions => 'Opzioni profilo';

  @override
  String homeAgendasOf(Object name) {
    return 'Agende di $name';
  }

  @override
  String get homeSettings => 'Impostazioni';

  @override
  String get homeImportAgenda => 'Importa agenda (.agviz)';

  @override
  String get homeNeeds => 'I miei bisogni';

  @override
  String get homeNeedsSubtitle => 'Tocca un\'immagine, la voce parla';

  @override
  String get homeEditBoard => 'Modifica la tavola';

  @override
  String get homeNoAgenda => 'Nessuna agenda. Creane una con +';

  @override
  String get homeStartChild => 'Avvia per il bambino';

  @override
  String get homeNewAgenda => 'Nuova agenda';

  @override
  String get agendaTypeDaily => 'Giornata';

  @override
  String get agendaTypeFirstThen => 'Prima–Poi';

  @override
  String get agendaTypeSequence => 'Sequenza';

  @override
  String get homeNewProfileTitle => 'Nuovo profilo';

  @override
  String get homeProfileNameLabel => 'Nome o soprannome';

  @override
  String get homeProfileNameHelper =>
      'Consigliato: solo il nome, niente cognome.\nResta solo su questo dispositivo.';

  @override
  String get homeCreate => 'Crea';

  @override
  String get homeRename => 'Rinomina';

  @override
  String get homeDelete => 'Elimina';

  @override
  String get homeRenameProfileTitle => 'Rinomina profilo';

  @override
  String get homeSave => 'Salva';

  @override
  String homeDeleteProfileQuestion(String name) {
    return 'Eliminare $name?';
  }

  @override
  String get homeDeleteProfileBody => 'Le sue agende non saranno più visibili.';

  @override
  String get homeCancel => 'Annulla';

  @override
  String get homeShareAgenda => 'Condividi (.agviz)';

  @override
  String get homeSharePhotosWarning =>
      'Se contiene foto, condividi solo con persone fidate';

  @override
  String get homeDeleteAgenda => 'Elimina';

  @override
  String homeShareFailed(String error) {
    return 'Condivisione non riuscita: $error';
  }

  @override
  String get homeImportSuccess => 'Agenda importata';

  @override
  String homeImportFailed(String error) {
    return 'Import non riuscito: $error';
  }

  @override
  String get homeNewAgendaTitle => 'Nuova agenda';

  @override
  String get homeAgendaTitleLabel => 'Titolo';

  @override
  String get homeAgendaTitleHint => 'Es. Routine mattina';

  @override
  String homeDeleteAgendaQuestion(String title) {
    return 'Eliminare \"$title\"?';
  }

  @override
  String homeShareText(String title) {
    return 'Agenda \"$title\" — apribile con Agenda Visiva';
  }

  @override
  String get builderPrintPdf => 'Stampa / PDF';

  @override
  String get builderPreview => 'Anteprima come bambino';

  @override
  String get builderEmpty => 'Aggiungi la prima attività';

  @override
  String get builderAddActivity => 'Aggiungi attività';

  @override
  String get builderFormat => 'Formato';

  @override
  String get builderGrid => 'Griglia';

  @override
  String get builderList => 'Elenco';

  @override
  String get builderPictogramsPerPage => 'Pittogrammi per pagina';

  @override
  String get builderPrint => 'Stampa';

  @override
  String get builderGridSubtitle => 'Ottimizzato per ritaglio e laminazione';

  @override
  String get builderListSubtitle => 'Elenco della giornata con orari e caselle';

  @override
  String get builderSharePdf => 'Condividi PDF';

  @override
  String get builderPreparingPdf => 'Preparo il PDF…';

  @override
  String get builderNeedActivity =>
      'Aggiungi almeno un\'attività prima di esportare';

  @override
  String builderExportFailed(String error) {
    return 'Export non riuscito: $error';
  }

  @override
  String get builderActivityName => 'Nome attività';

  @override
  String get builderAdd => 'Aggiungi';

  @override
  String get builderItemOptions => 'Opzioni attività';

  @override
  String get builderTimer => 'Timer visivo';

  @override
  String get builderTimes => 'Orario inizio e fine';

  @override
  String get builderBadges => 'Dove e con chi';

  @override
  String get builderRemove => 'Rimuovi dall\'agenda';

  @override
  String get builderStartTimeHelp => 'Orario di inizio (Annulla = nessuno)';

  @override
  String get builderEndTimeHelp => 'Orario di fine (Annulla = nessuno)';

  @override
  String get builderWhereHint => 'Dove (es. Palestra)';

  @override
  String get builderWithWhoHint => 'Con chi (es. Maria)';

  @override
  String get builderChoosePictogram => 'Scegli pittogramma';

  @override
  String get builderCancel => 'Annulla';

  @override
  String get builderSave => 'Salva';

  @override
  String get builderTimerTitle => 'Timer visivo';

  @override
  String get builderNoTimer => 'Nessuno';

  @override
  String builderMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti',
      one: '1 minuto',
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
  String get playerNeeds => 'I miei bisogni';

  @override
  String get playerExitHint =>
      'Per uscire, tieni premuta la freccia per 3 secondi';

  @override
  String get playerEmpty => 'Agenda vuota';

  @override
  String get playerAfter => 'Dopo: ';

  @override
  String get playerNow => 'Adesso';

  @override
  String get playerDone => 'Fatto';

  @override
  String get playerDoneExclamation => 'Fatto!';

  @override
  String get playerFinished => 'Hai finito!';

  @override
  String get playerRestart => 'Ricomincia';

  @override
  String playerEndOnly(String end) {
    return '– $end';
  }

  @override
  String playerTimeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get needsBoardTitle => 'I miei bisogni';

  @override
  String get needsBoardEmpty =>
      'Chiedi a un adulto di aggiungere i bisogni dalla matita nella schermata delle agende.';

  @override
  String get needsBoardEditTitle => 'I miei bisogni — modifica';

  @override
  String get needsBoardEmptyAdult => 'La tavola è vuota';

  @override
  String get needsBoardSeed => 'Aggiungi bisogni di base';

  @override
  String get needsBoardAdvice =>
      'Consiglio: tieni la tavola corta (6-8 bisogni). Poche scelte chiare aiutano più di tante.';

  @override
  String get needsBoardAdd => 'Aggiungi';

  @override
  String get needsBoardWord => 'Parola da pronunciare';

  @override
  String get pickerTitle => 'Scegli un pittogramma';

  @override
  String get pickerArasaac => 'ARASAAC';

  @override
  String get pickerPhoto => 'Foto';

  @override
  String get pickerBuiltin => 'Base';

  @override
  String get pickerSearchHint => 'Cerca (es. colazione, cerchio, bagno)';

  @override
  String get pickerOfflineError =>
      'Ricerca non riuscita. Sei offline? Le ricerche già fatte funzionano anche senza rete.';

  @override
  String get pickerSearchPrompt =>
      'Scrivi per cercare tra migliaia di pittogrammi';

  @override
  String get pickerNoResults => 'Nessun risultato';

  @override
  String get pickerGallery => 'Scegli dalla galleria';

  @override
  String get pickerCamera => 'Scatta una foto';

  @override
  String get pickerPhotoPrivacy =>
      'La foto resta solo su questo dispositivo. Posizione e metadati (EXIF) vengono rimossi automaticamente.';

  @override
  String get pickerCameraError =>
      'Fotocamera non disponibile su questo dispositivo';
}
