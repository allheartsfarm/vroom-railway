#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla configuration..."

# Debug environment
echo "=== ENVIRONMENT ==="
echo "PORT: ${PORT:-not set}"
echo "VROOM_ROUTER: ${VROOM_ROUTER:-not set}"
echo "VALHALLA_HOST: ${VALHALLA_HOST:-not set}"
echo "VALHALLA_PORT: ${VALHALLA_PORT:-not set}"
echo "VALHALLA_USE_HTTPS: ${VALHALLA_USE_HTTPS:-not set}"
echo "==================="

# Defaults
PORT=${PORT:-8080}
VROOM_ROUTER=${VROOM_ROUTER:-valhalla}
VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
VALHALLA_PORT=${VALHALLA_PORT:-443}
VALHALLA_USE_HTTPS=${VALHALLA_USE_HTTPS:-true}

mkdir -p /conf

# Generate config for Valhalla
cat > /conf/config.yml <<YAML
cliArgs:
  geometry: false
  planmode: false
  threads: 4
  explore: 5
  limit: '1mb'
  logdir: '/..'
  logsize: '100M'
  maxlocations: 1000
  maxvehicles: 200
  override: true
  path: ''
  host: '0.0.0.0'
  port: ${PORT}
  router: '${VROOM_ROUTER}'
  timeout: 10000
  baseurl: '/'
routingServers:
  valhalla:
    car:
      host: '${VALHALLA_HOST}'
      port: ${VALHALLA_PORT}
      use_https: ${VALHALLA_USE_HTTPS}
    bike:
      host: '${VALHALLA_HOST}'
      port: ${VALHALLA_PORT}
      use_https: ${VALHALLA_USE_HTTPS}
    foot:
      host: '${VALHALLA_HOST}'
      port: ${VALHALLA_PORT}
      use_https: ${VALHALLA_USE_HTTPS}
    auto:
      host: '${VALHALLA_HOST}'
      port: ${VALHALLA_PORT}
      use_https: ${VALHALLA_USE_HTTPS}
YAML

echo "=== RENDERED /conf/config.yml ==="
cat /conf/config.yml
echo "=================================="

# Test if vroom-express exists
echo "=== TESTING VROOM-EXPRESS ==="
which vroom-express || echo "vroom-express not found in PATH"
ls -la /usr/local/bin/ | grep vroom || echo "No vroom binaries in /usr/local/bin/"
echo "=============================="

# Hand off to upstream entrypoint which starts vroom-express
exec /bin/bash /docker-entrypoint.sh
