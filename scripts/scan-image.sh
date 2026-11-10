#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -S "$PWD/.tmp/docker3.sock" ]]; then
  export DOCKER_HOST="unix://$PWD/.tmp/docker3.sock"
fi

IMAGE="${1:?Uso: scan-image.sh IMAGEN [SALIDA]}"
OUT="${2:-evidence/trivy-$(echo "$IMAGE" | tr '/:' '--')-critical.txt}"

trivy image \
  --scanners vuln \
  --severity CRITICAL \
  --no-progress \
  --timeout 15m \
  "$IMAGE" 2>&1 | tee "$OUT"

COUNT="$(grep -c '^┌\|CRITICAL' "$OUT" || true)"
echo
echo "Resumen: $IMAGE -> $OUT"
