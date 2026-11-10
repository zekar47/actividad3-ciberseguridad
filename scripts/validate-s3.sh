#!/usr/bin/env bash
set -euo pipefail

BUCKET="actividad3-seguro-2024"

echo "== Cifrado del bucket =="
awslocal s3api get-bucket-encryption --bucket "$BUCKET" | jq .

echo
echo "== Bloqueo de acceso público =="
awslocal s3api get-public-access-block --bucket "$BUCKET" | jq .

echo
echo "== Estatus de política pública =="
# LocalStack Community aún no implementa get-bucket-policy-status; el bloqueo
# público ya quedó demostrado con get-public-access-block. Se intenta y, si no
# está disponible, se continúa con la política explícita del bucket.
if ! awslocal s3api get-bucket-policy-status --bucket "$BUCKET" 2>/dev/null | jq .; then
  echo "(No implementado en LocalStack Community; se valida con la política explícita.)"
fi

echo
echo "== Política del bucket =="
awslocal s3api get-bucket-policy --bucket "$BUCKET" | jq -r '.Policy' | jq .
