#!/usr/bin/env bash
# Levanta un daemon Docker local para este proyecto.
#
# El kernel de este equipo no expone el controlador de dispositivos por
# cgroup v2 (CONFIG_BPF_SYSCALL no está habilitado), por lo que runc falla al
# crear contenedores. El daemon local usa user namespaces y un wrapper de runc
# en modo rootless para evitar ese controlador. En un equipo con Docker
# estándar este script no es necesario.
set -euo pipefail

cd "$(dirname "$0")/.."

SOCKET="$PWD/.tmp/docker3.sock"
PIDFILE="$PWD/.tmp/docker3.pid"
DATA_ROOT="/tmp/opencode/act3-docker-data"
EXEC_ROOT="/tmp/opencode/act3-docker-exec"
RUNC_WRAPPER="/tmp/opencode/runc-rootless"

if [[ -S "$SOCKET" ]] && DOCKER_HOST="unix://$SOCKET" docker info >/dev/null 2>&1; then
  echo "El daemon Docker local ya está activo en $SOCKET"
  exit 0
fi

mkdir -p "$PWD/.tmp" "$DATA_ROOT" "$EXEC_ROOT"

cat > "$RUNC_WRAPPER" <<'EOF'
#!/bin/sh
exec /usr/bin/runc --rootless true "$@"
EOF
chmod +x "$RUNC_WRAPPER"

sudo dockerd \
  --host "unix://$SOCKET" \
  --data-root "$DATA_ROOT" \
  --exec-root "$EXEC_ROOT" \
  --pidfile "$PIDFILE" \
  --userns-remap=default \
  --add-runtime runc-rootless="$RUNC_WRAPPER" \
  --default-runtime runc-rootless \
  --iptables=true \
  --ip6tables=false \
  --ip-forward=true \
  --ip-masq=true \
  > "$PWD/.tmp/dockerd.log" 2>&1 &

for _ in $(seq 1 40); do
  if [[ -S "$SOCKET" ]]; then
    break
  fi
  sleep 1
done

if [[ ! -S "$SOCKET" ]]; then
  echo "No se pudo iniciar el daemon Docker local. Revisa .tmp/dockerd.log" >&2
  exit 1
fi

sudo setfacl -m "u:$(id -un):rw" "$SOCKET"
export DOCKER_HOST="unix://$SOCKET"
docker info --format 'Docker local listo: {{.ServerVersion}} ({{.Driver}})'
