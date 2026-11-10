#!/usr/bin/env bash
set -euo pipefail

BASE="${API_BASE:-http://127.0.0.1:3000}"

req() {
  local method="$1" path="$2" token="${3:-}" body="${4:-}"
  local args=(-sS -o /tmp/opencode/api-body.json -w '%{http_code}' -X "$method" "$BASE$path")
  [[ -n "$token" ]] && args+=(-H "Authorization: Bearer $token")
  [[ -n "$body" ]] && args+=(-H 'Content-Type: application/json' -d "$body")
  local code
  code="$(curl "${args[@]}")"
  printf 'HTTP %s  %s %s\n' "$code" "$method" "$path"
  jq . /tmp/opencode/api-body.json 2>/dev/null || cat /tmp/opencode/api-body.json
  echo
}

echo "== Estado del servicio =="
req GET /health

echo "== Inicio de sesión (admin) =="
ADMIN_TOKEN="$(curl -sS -X POST "$BASE/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"Admin#2024"}' | jq -r .access_token)"
echo "Token JWT emitido (primeros 40 caracteres): ${ADMIN_TOKEN:0:40}..."
echo

echo "== Inicio de sesión (analista) =="
ANALYST_TOKEN="$(curl -sS -X POST "$BASE/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"username":"analista","password":"Analista#2024"}' | jq -r .access_token)"
echo "Token JWT emitido (primeros 40 caracteres): ${ANALYST_TOKEN:0:40}..."
echo

echo "== /api/profile sin token (debe ser 401) =="
req GET /api/profile

echo "== /api/profile con token admin (debe ser 200) =="
req GET /api/profile "$ADMIN_TOKEN"

echo "== /api/admin con token admin (debe ser 200) =="
req GET /api/admin "$ADMIN_TOKEN"

echo "== /api/admin con token de analista (debe ser 403) =="
req GET /api/admin "$ANALYST_TOKEN"

echo "== /api/reports con token de analista (debe ser 200) =="
req GET /api/reports "$ANALYST_TOKEN"

echo "== /api/profile con token inválido (debe ser 401) =="
req GET /api/profile "token.invalido.firmado"

echo "== Credenciales incorrectas (debe ser 401) =="
req POST /auth/login "" '{"username":"admin","password":"incorrecta"}'
