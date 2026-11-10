#!/usr/bin/env bash
set -euo pipefail

BASE="${API_BASE:-http://127.0.0.1:3000}"

login() {
  curl -sS -X POST "$BASE/auth/login" \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"$1\",\"password\":\"$2\"}"
}

ADMIN_TOKEN="$(login admin 'Admin#2024' | jq -r .access_token)"
ANALYST_TOKEN="$(login analista 'Analista#2024' | jq -r .access_token)"

echo "== POST /auth/login (admin) =="
login admin 'Admin#2024' \
  | jq '{token_type, expires_in, user, access_token: (.access_token[0:36] + "...")}'

echo
echo "== GET /api/profile (token de admin) =="
curl -sS -H "Authorization: Bearer $ADMIN_TOKEN" "$BASE/api/profile" | jq .

echo
echo "== GET /api/admin (token de analista, debe ser 403) =="
curl -sS -o /tmp/opencode/jwt-demo-body.json -w 'HTTP %{http_code}\n' \
  -H "Authorization: Bearer $ANALYST_TOKEN" "$BASE/api/admin"
jq . /tmp/opencode/jwt-demo-body.json
