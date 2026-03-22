#!/usr/bin/env bash
# Build release AAB for Google Play. Run from repo root: frontend/frontend (Flutter app root).
set -e
cd "$(dirname "$0")/.."
echo "Building release AAB..."
flutter build appbundle --release
AAB="build/app/outputs/bundle/release/app-release.aab"
if [[ -f "$AAB" ]]; then
  echo "Done. AAB: $(pwd)/$AAB"
  echo "Upload this file in Play Console: Release → Production (or Internal testing) → App bundles → Upload."
else
  echo "Error: AAB not found at $AAB"
  exit 1
fi
