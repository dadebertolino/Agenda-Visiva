# Pubblicazione desktop: Mac App Store e Microsoft Store

Procedura per rilasciare Agenda Visiva su macOS e Windows. Vale la stessa
promessa delle versioni mobile: nessun account, nessuna pubblicità, nessuna
raccolta dati. I questionari degli store vanno compilati in modo coerente
con quelli di App Store (iOS) e Google Play.

## Prima di ogni rilascio

- `version` in `pubspec.yaml` e `K.appVersion` in `lib/core/constants.dart`
  allineati (es. `1.3.0+6` e `'1.3.0'`).
- CI verde, compresi i job `Desktop` (Windows e macOS).
- Privacy policy aggiornata su davidebertolino.it (foto **e voci registrate**
  restano sul dispositivo).

## macOS — Mac App Store

Il bundle ID è lo stesso di iOS (`it.davidebertolino.agendaVisiva`): l'app
macOS si aggiunge alla scheda esistente in App Store Connect come
**piattaforma macOS** (acquisto universale). Non serve un'app nuova.

1. App Store Connect → app Agenda Visiva → **+ Piattaforma → macOS**.
2. Build:
   ```bash
   flutter build macos --release
   open macos/Runner.xcworkspace
   ```
   In Xcode: target Runner → Signing & Capabilities → team di firma; poi
   **Product → Archive → Distribute App → App Store Connect**.
3. Scheda macOS: screenshot (1280×800 o superiore, profili con nomi di
   fantasia, nessuna foto reale di bambini), stessa descrizione con frame
   adulto ("per insegnanti e famiglie").
4. Categoria **Education**. L'etichetta privacy è condivisa con iOS:
   **Data Not Collected** resta vero.
5. Revisione: se chiedono del microfono, l'audio è registrato e riprodotto
   solo in locale (entitlement `device.audio-input`, nessuna trasmissione).

Entitlements della sandbox (`macos/Runner/*.entitlements`): rete in uscita
(solo ARASAAC), microfono, file scelti dall'utente, stampa. Nient'altro.

## Windows — Microsoft Store

1. Partner Center (account sviluppatore individuale) → **Nuova app** →
   prenota il nome "Agenda Visiva".
2. Partner Center → app → **Gestione prodotti → Identità del prodotto**:
   copia `Package/Identity/Name` e `Package/Identity/Publisher` in
   `msix_config` di `pubspec.yaml` al posto dei valori `SEGNAPOSTO`.
3. Il pacchetto si crea solo su Windows. Due strade:
   - **CI**: la run del workflow `Desktop` produce l'artifact
     `agenda-visiva-msix` (scaricabile dalla pagina della run).
   - **PC Windows**:
     ```bash
     flutter build windows --release
     dart run msix:create --build-windows false
     ```
   Il file è in `build/windows/x64/runner/Release/agenda_visiva.msix`.
   Non serve firmarlo: lo firma Microsoft al momento dell'invio.
4. Invio in Partner Center:
   - **Categoria**: Istruzione.
   - **Fasce d'età (IARC)**: nessun contenuto generato dagli utenti condiviso
     online, nessuna chat, nessun acquisto. L'utente è l'adulto.
   - **Privacy policy**: obbligatoria (l'app usa microfono e internet):
     URL della pagina privacy di Agenda Visiva.
   - **Raccolta dati**: nessun dato raccolto né trasmesso.
   - Descrizione e screenshot con lo stesso frame adulto.

Capability dichiarate nel pacchetto: `internetClient` (solo ARASAAC) e
`microphone` (voce registrata). Nient'altro.

## Differenze rispetto al mobile

- **Fotocamera**: su desktop c'è solo "Scegli dalla galleria".
- **Foto su Windows**: la pulizia EXIF/GPS e il ridimensionamento sono fatti
  in Dart puro (`stripAndResizeJpeg` in `media_store.dart`), con la stessa
  garanzia del plugin nativo. È coperta da un test.
- **Voce di sistema**: la lettura vocale usa le voci installate nel sistema;
  su Windows potrebbe servire aggiungere la voce italiana (Impostazioni →
  Ora e lingua → Voce).
