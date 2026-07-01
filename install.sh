#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ "${1:-}" == "--upgrade" ]]; then
  kpackagetool6 --type Plasma/Applet --upgrade "$PWD"
else
  kpackagetool6 --type Plasma/Applet --install "$PWD"
fi

