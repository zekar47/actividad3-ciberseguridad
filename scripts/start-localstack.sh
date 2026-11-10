#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -S "$PWD/.tmp/docker3.sock" ]]; then
  export DOCKER_HOST="unix://$PWD/.tmp/docker3.sock"
fi

mkdir -p .localstack .tmp
chmod 777 .localstack

docker-compose up -d

# El daemon local no puede publicar puertos con DNAT (el kernel no incluye
# xt_nat), así que el puerto 4566 se reenvía con socat desde el host.
CONTAINER_IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' actividad3-localstack)"
if [[ -z "$CONTAINER_IP" ]]; then
  echo "No se pudo obtener la IP del contenedor de LocalStack." >&2
  exit 1
fi

pkill -f '[s]ocat TCP-LISTEN:4566' 2>/dev/null || true
nohup socat TCP-LISTEN:4566,fork,reuseaddr "TCP:$CONTAINER_IP:4566" \
  > .tmp/socat.log 2>&1 &
echo "LocalStack en $CONTAINER_IP:4566, reenviado a localhost:4566 con socat."

echo "Esperando a que LocalStack esté listo..."
for _ in $(seq 1 60); do
  if curl -fsS "http://localhost:4566/_localstack/health" >/dev/null 2>&1; then
    curl -s "http://localhost:4566/_localstack/health" | jq .
    exit 0
  fi
  sleep 2
done

echo "LocalStack no respondió en el tiempo esperado." >&2
exit 1
