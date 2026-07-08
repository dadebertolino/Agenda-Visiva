# Agenda Visiva

**Agende visive e comunicazione dei bisogni per bambini autistici e con svantaggio linguistico.**
Codice pubblico e gratuito per sempre. Uso commerciale vietato ([PolyForm Noncommercial 1.0.0](LICENSE.md)).

*Visual schedules and a basic AAC needs board for autistic children and children with language difficulties, built for Italian schools and families. Free forever, source-available, commercial use prohibited. Offline-first: children's names and photos never leave the device.*

Pagina del progetto: [davidebertolino.it/agenda-visiva/](https://davidebertolino.it/agenda-visiva/) · Privacy: [davidebertolino.it/privacy-policy-agenda-visiva/](https://davidebertolino.it/privacy-policy-agenda-visiva/)

## Perché

Le agende visive (TEACCH, CAA) riducono l'ansia da transizione e aumentano l'autonomia. Gli strumenti esistenti sono in inglese, a pagamento, o poco rispettosi della privacy. Agenda Visiva è pensata con e per insegnanti italiani di infanzia e primaria, in co-design con chi la usa in classe.

## Principi non negoziabili

1. **Offline-first, zero tracker**: nessun account, nessun backend, nessun SDK di analytics o ads. Verificato in CI da `tool/check_denylist.sh` — la build fallisce se compare un pacchetto vietato.
2. **Privacy by design**: foto e nomi dei bambini restano sul dispositivo. Le foto importate sono ridimensionate e ripulite dai metadati EXIF/GPS. Nessun campo diagnosi nel data model. I file condivisi (.agviz) non contengono mai il nome del bambino.
3. **Filtro bambini non disattivabile** sui pittogrammi ARASAAC (flag `sex`/`violence` esclusi lato client).
4. **Gratuita per sempre**: nessun acquisto in-app, nessuna pubblicità.

## Funzionalità

- **Editor agenda** drag & drop: tre tipi (Giornata, Prima–Poi, Sequenza), timer visivo per attività, riuso rapido delle attività recenti
- **Pittogrammi**: ricerca ARASAAC in italiano (cache offline), foto personali, set base incluso
- **Modalità bambino**: full-screen, card grandi (dimensione regolabile), avanzamento con check-off, timer analogico ad anello, lettura vocale (TTS it-IT), schermata di rinforzo a fine agenda
- **Tavola "I miei bisogni"**: griglia di comunicazione CAA — il bambino tocca l'immagine (Acqua, Bagno, Aiuto...), il dispositivo pronuncia la parola; modificabile dall'adulto, raggiungibile anche durante la routine
- **Profili multipli** con impostazioni individuali (voce, contrasto, dimensione pittogrammi)
- **Export PDF** con 1, 2 o 4 pittogrammi per pagina, ottimizzato per ritaglio e laminazione + stampa diretta
- **Condivisione casa↔scuola senza server**: formato `.agviz` (export/import idempotente via file)

## Piattaforme

iOS e Android da un unico codebase Flutter. Nota Android: il permesso `INTERNET` in `AndroidManifest.xml` serve esclusivamente ai pittogrammi ARASAAC (unica comunicazione di rete dell'app).

## Setup sviluppo

```bash
# Prerequisiti: Flutter stable >= 3.22
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run flutter_native_splash:create
dart run flutter_launcher_icons
flutter test
flutter run
```

Per iOS: aprire `ios/Runner.xcworkspace` e impostare il team di firma. Per Android release: `flutter build apk --release` (o `appbundle` per il Play Store, con keystore proprio).

## Architettura

Feature-first, offline-first, sync-ready (UUID client-side, tombstone, campo `dirty` su ogni tabella: la futura sync E2E non richiederà migrazioni). Database drift con migrazioni versionate (attuale: v2).

```
lib/
  core/          costanti, provider root, widget condivisi
  data/
    db/          drift (SQLite): tabelle, migrazioni
    repositories/  Profile, Agenda, Activity, Board — le feature dipendono da qui, mai da drift
    services/    arasaac_api, media_store, pdf_export, agviz, tts
  domain/        modelli puri (ProfileSettings, ...)
  features/      profiles, builder, player, pictogram_picker, comunicazione, settings
```

Stack: Riverpod 2, drift, pdf/printing, flutter_tts. Dettagli e razionali in `docs/`.

## Roadmap

- [x] MVP completo (editor, player, ARASAAC, foto, PDF parametrico, .agviz, impostazioni, tavola bisogni)
- [ ] Pilota in una sezione di scuola dell'infanzia (in partenza) e iterazione col feedback
- [ ] Pubblicazione App Store (in corso) e Play Store
- [ ] Suoni di conferma e rifinitura accessibilità (alto contrasto)
- [ ] Fase 2: sync casa-scuola con crittografia end-to-end (il server vedrà solo blob cifrati) — DPIA pubblica in questo repo

## Feedback

Sei un insegnante, genitore, educatore o terapista? Il tuo parere orienta la roadmap: apri una [Issue](../../issues) o scrivi a info@davidebertolino.it.

## Crediti e licenze

- Codice: © Davide Bertolino, licenza [PolyForm Noncommercial 1.0.0](LICENSE.md)
- Pittogrammi: Sergio Palao / [ARASAAC](https://arasaac.org), proprietà del Governo di Aragona, licenza CC BY-NC-SA

## Autore

Made by Prof. Davide Bertolino — contatti: info@davidebertolino.it · [davidebertolino.it](https://davidebertolino.it)