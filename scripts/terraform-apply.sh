#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform"

terraform init -input=false
terraform validate
terraform plan -out=tfplan
terraform apply -input=false -auto-approve tfplan
