#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../api"

if [[ -f ../.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source ../.env
  set +a
fi

if [[ -z "${JWT_SECRET:-}" ]]; then
  echo "Falta JWT_SECRET. Revisa el archivo .env de la raíz del proyecto." >&2
  exit 1
fi

exec node server.js
