# Agenda Visiva

**Agende visive per bambini autistici e con svantaggio linguistico.**
Codice pubblico e gratuito per sempre. Uso commerciale vietato ([PolyForm NC 1.0.0](LICENSE.md)).

*Visual schedules for autistic children and children with language difficulties. Free forever, source-available, commercial use prohibited.*

## Principi non negoziabili

1. **Offline-first, zero tracker**: nessun account, nessun backend, nessun SDK di analytics/ads. Verificato in CI da `tool/check_denylist.sh`.
2. **Privacy by design**: foto e nomi dei bambini non lasciano mai il dispositivo. Nessun campo diagnosi nel data model.
3. **Filtro bambini non disattivabile** sui pittogrammi ARASAAC (flag `sex`/`violence`).
4. **Gratuita per sempre**: nessun acquisto in-app, nessuna pubblicità.

## Setup sviluppo

```bash
# Prerequisiti: Flutter stable >= 3.22
flutter create . --org it.davidebertolino --platforms ios,android
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

`flutter create .` genera le cartelle piattaforma (ios/, android/) senza toccare `lib/`.

## Architettura

Feature-first, offline-first, sync-ready. Vedi `docs/` per data model e decisioni:

```
lib/
  core/          costanti e tema
  data/
    db/          drift: tabelle, migrazioni (schema sync-ready: UUID, tombstone, dirty)
    repositories/  le feature dipendono da qui, MAI da drift
    services/    arasaac_api, tts, pdf_export
  domain/        modelli freezed
  features/      profiles, builder, player, pictogram_picker, export, settings
```

## Crediti

Pittogrammi: Sergio Palao / [ARASAAC](https://arasaac.org), Governo di Aragona, licenza CC BY-NC-SA.
