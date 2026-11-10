#!/usr/bin/env bash
set -euo pipefail

if [[ -S "$PWD/.tmp/docker3.sock" ]]; then
  export DOCKER_HOST="unix://$PWD/.tmp/docker3.sock"
fi

IMAGE="${1:?Uso: trivy-summary.sh IMAGEN}"

trivy image \
  --scanners vuln \
  --severity CRITICAL \
  --no-progress \
  --format json \
  "$IMAGE" 2>/dev/null \
| jq -r --arg img "$IMAGE" '
    "Imagen: \($img)",
    "Vulnerabilidades CRITICAL totales: \([.Results[]?.Vulnerabilities[]?] | length)",
    "",
    (.Results[]? | select(.Vulnerabilities != null)
      | "  \(.Target): \(.Vulnerabilities | length) críticas")
  '
