#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla configuration..."

# Defaults
PORT=${PORT:-8080}
VROOM_ROUTER=${VROOM_ROUTER:-valhalla}
VALHALLA_HOST=${VALHALLA_HOST:-valhalla}
VALHALLA_PORT=${VALHALLA_PORT:-8080}
VALHALLA_USE_HTTPS=${VALHALLA_USE_HTTPS:-false}

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

# Hand off to upstream entrypoint which starts vroom-express
exec /bin/bash /docker-entrypoint.sh
