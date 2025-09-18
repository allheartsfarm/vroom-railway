#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla routing..."

# Defaults
PORT=${PORT:-8080}
VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
VALHALLA_PORT=${VALHALLA_PORT:-443}
VALHALLA_USE_HTTPS=${VALHALLA_USE_HTTPS:-true}

mkdir -p /conf

# Create a custom config that uses Valhalla as a routing server
# Since VROOM doesn't natively support Valhalla, we'll configure it to work
# by treating Valhalla as an external routing service
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
  router: 'osrm'
  timeout: 30000
  baseurl: '/'
routingServers:
  osrm:
    car:
      - host: '${VALHALLA_HOST}'
        port: ${VALHALLA_PORT}
        use_https: ${VALHALLA_USE_HTTPS}
    bike:
      - host: '${VALHALLA_HOST}'
        port: ${VALHALLA_PORT}
        use_https: ${VALHALLA_USE_HTTPS}
    foot:
      - host: '${VALHALLA_HOST}'
        port: ${VALHALLA_PORT}
        use_https: ${VALHALLA_USE_HTTPS}
YAML

echo "=== VROOM CONFIG ==="
cat /conf/config.yml
echo "===================="

# Start vroom-express
exec vroom-express