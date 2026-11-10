#!/usr/bin/env bash
# Muestra la estructura del repositorio sin archivos locales ni artefactos.
set -euo pipefail

cd "$(dirname "$0")/.."

find . -maxdepth 2 \
  \( -path './.git' -o -path './.git/*' \
     -o -path './.tmp' -o -path './.tmp/*' \
     -o -path './.cache' -o -path './.cache/*' \
     -o -path './.localstack' -o -path './.localstack/*' \
     -o -path './.zap*' -o -path './.zap*/*' \
     -o -path './.aws' -o -path './.aws/*' \
     -o -path './.terraform' -o -path './.terraform/*' \
     -o -path './terraform/.terraform' -o -path './terraform/.terraform/*' \
     -o -path './api/node_modules' -o -path './api/node_modules/*' \
     -o -name '.env' -o -name '.terraform.lock.hcl' \
     -o -name 'header.tex' -o -name 'Makefile' -o -name '*.pdf' \
     -o -name 'references.bib' -o -name 'instrucciones.txt' \
     -o -name 'test.gif' -o -name 'test.png' \
     -o -name 'trivy-node*-critical.txt' \
     -o -name '*.tfstate*' -o -name 'tfplan' \) -prune \
  -o -print | sort
