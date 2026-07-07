#!/usr/bin/env bash
# Vincolo di progetto verificabile: ZERO tracker, analytics, ads.
# Fallisce la CI se in pubspec compare un pacchetto vietato.
set -euo pipefail

DENY=(firebase google_mobile_ads sentry mixpanel amplitude facebook appsflyer
      adjust onesignal crashlytics posthog segment datadog branch_io)

fail=0
for pkg in "${DENY[@]}"; do
  if grep -qi "$pkg" pubspec.yaml; then
    echo "VIETATO: '$pkg' trovato in pubspec.yaml (policy zero-tracker)"
    fail=1
  fi
done

if [ "$fail" -eq 1 ]; then exit 1; fi
echo "OK: nessun pacchetto tracker/analytics/ads in pubspec.yaml"
