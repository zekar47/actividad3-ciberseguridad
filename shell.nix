{ pkgs ? import <nixpkgs> { } }:

let
  # awslocal es el wrapper de awscli-local: apunta la AWS CLI a LocalStack.
  awslocal = pkgs.writeShellScriptBin "awslocal" ''
    exec ${pkgs.awscli2}/bin/aws \
      --endpoint-url "''${LOCALSTACK_ENDPOINT:-http://localhost:4566}" \
      "$@"
  '';
in
pkgs.mkShell {
  name = "actividad3-ciberseguridad";

  packages = with pkgs; [
    terraform
    awscli2
    awslocal
    trivy
    nodejs_22
    jq
    curl
    socat
    docker-compose
    vhs
    ttyd
    ffmpeg
    zap
    mermaid-cli
    graphviz
    imagemagick
    pandoc
    python3
  ];

  shellHook = ''
    export AWS_CONFIG_FILE="$PWD/.aws/config"
    export AWS_SHARED_CREDENTIALS_FILE="$PWD/.aws/credentials"
    export AWS_DEFAULT_REGION="us-east-1"
    export AWS_ACCESS_KEY_ID="test"
    export AWS_SECRET_ACCESS_KEY="test"
    export AWS_PAGER=""
    export LOCALSTACK_ENDPOINT="http://localhost:4566"
    export TRIVY_CACHE_DIR="$PWD/.cache/trivy"
    export npm_config_cache="$PWD/.cache/npm"
    export ZAP_HOME="$PWD/.zap"
    export TMPDIR="$PWD/.tmp"

    mkdir -p "$PWD/.aws" "$PWD/.cache/trivy" "$PWD/.cache/npm" \
             "$PWD/.zap" "$PWD/.tmp"

    cat > "$AWS_CONFIG_FILE" <<'EOF'
[default]
region = us-east-1
output = json
EOF

    cat > "$AWS_SHARED_CREDENTIALS_FILE" <<'EOF'
[default]
aws_access_key_id = test
aws_secret_access_key = test
EOF

    echo "Entorno Actividad 3 listo."
    echo "  aws:        $(aws --version 2>&1 | cut -d' ' -f1-2)"
    echo "  terraform:  $(terraform version -json 2>/dev/null | jq -r .terraform_version)"
    echo "  trivy:      $(trivy --version | head -1)"
    echo "  node:       $(node --version)"
    echo "  awslocal:   $(awslocal --version 2>&1 | cut -d' ' -f1-2)"
    echo "  endpoint:   $LOCALSTACK_ENDPOINT"
  '';
}
