#!/usr/bin/env bash
set -euo pipefail

ROLE="actividad3-app-role"
POLICY_ARN="arn:aws:iam::000000000000:policy/actividad3-s3-read-only"

echo "== Rol de aplicación =="
awslocal iam get-role --role-name "$ROLE" \
  | jq '{Role: {RoleName: .Role.RoleName, Arn: .Role.Arn, AssumeRolePolicyDocument: .Role.AssumeRolePolicyDocument}}'

echo
echo "== Políticas administradas adjuntas al rol =="
awslocal iam list-attached-role-policies --role-name "$ROLE" | jq .

echo
echo "== Políticas inline del rol (debe estar vacío: no hay permisos embebidos) =="
awslocal iam list-role-policies --role-name "$ROLE" | jq .

echo
echo "== Documento de la política de permisos mínimos =="
VERSION="$(awslocal iam get-policy --policy-arn "$POLICY_ARN" --query 'Policy.DefaultVersionId' --output text)"
awslocal iam get-policy-version --policy-arn "$POLICY_ARN" --version-id "$VERSION" \
  | jq '.PolicyVersion.Document'

echo
echo "== Acciones permitidas (resumen) =="
awslocal iam get-policy-version --policy-arn "$POLICY_ARN" --version-id "$VERSION" \
  | jq -r '.PolicyVersion.Document.Statement[] | "\(.Effect): \(.Action | if type=="array" then join(", ") else . end) sobre \(.Resource)"'
