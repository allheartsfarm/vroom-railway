#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla routing..."

# Defaults
PORT=${PORT:-8080}
VROOM_ROUTER=${VROOM_ROUTER:-valhalla}
VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
VALHALLA_PORT=${VALHALLA_PORT:-443}
VALHALLA_USE_HTTPS=${VALHALLA_USE_HTTPS:-true}

mkdir -p /conf

# Create VROOM configuration for OSRM
cat > /conf/config.yml <<YAML
cliArgs:
  geometry: true
  planmode: false
  threads: 4
  explore: 5
  limit: '1mb'
  logdir: '/conf'
  logsize: '100M'
  maxlocations: 1000
  maxvehicles: 200
  override: true
  path: ''
  host: '0.0.0.0'
  port: ${PORT}
  router: 'valhalla'
  timeout: 30000
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

echo "=== VROOM CONFIG ==="
cat /conf/config.yml
echo "===================="

# Start vroom using the default command from the image
exec vroom-express 