#!/usr/bin/env bash
set -euo pipefail

# Defaults (can be overridden by env)
PORT=${PORT:-3000}
VROOM_ROUTER=${VROOM_ROUTER:-osrm}
VROOM_LOG=${VROOM_LOG:-/conf}

VALHALLA_HOST=${VALHALLA_HOST:-valhalla}
VALHALLA_PORT=${VALHALLA_PORT:-8080}

OSRM_HOST=${OSRM_HOST:-osrm}
OSRM_PORT=${OSRM_PORT:-5000}

ORS_HOST=${ORS_HOST:-ors}
ORS_PORT=${ORS_PORT:-8080}

mkdir -p /conf

# Optional: force config regeneration on each boot when set
if [[ "${FORCE_CONFIG_REWRITE:-}" == "1" ]]; then
  rm -f /conf/config.yml || true
fi

# Only (re)write config if none present, so you can tweak in container
if [[ ! -f /conf/config.yml ]]; then
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
  port: ${PORT}
  router: '${VROOM_ROUTER}'
  timeout: 300000
  baseurl: '/'
routingServers:
  osrm:
    car:
      host: '${OSRM_HOST}'
      port: '${OSRM_PORT}'
    bike:
      host: '${OSRM_HOST}'
      port: '${OSRM_PORT}'
    foot:
      host: '${OSRM_HOST}'
      port: '${OSRM_PORT}'
  ors:
    driving-car:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
    driving-hgv:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
    cycling-regular:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
    cycling-mountain:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
    cycling-road:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
    cycling-electric:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
    foot-walking:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
    foot-hiking:
      host: '${ORS_HOST}/ors/v2'
      port: '${ORS_PORT}'
  valhalla:
    auto:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    bicycle:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    pedestrian:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    motorcycle:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    motor_scooter:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    taxi:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    hov:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    truck:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
    bus:
      host: '${VALHALLA_HOST}'
      port: '${VALHALLA_PORT}'
YAML
fi

# Ensure access.log exists for vroom-express
touch /conf/access.log

# Ensure vroom-express uses Railway's PORT
export PORT=${PORT:-3000}

# Try to modify the vroom-express startup by overriding the package.json start script
if [ -f /usr/local/lib/node_modules/vroom-express/package.json ]; then
  # Backup original package.json
  cp /usr/local/lib/node_modules/vroom-express/package.json /usr/local/lib/node_modules/vroom-express/package.json.bak
  
  # Modify the start script to use the correct port
  sed -i "s/\"start\": \".*\"/\"start\": \"node src\/index.js --port ${PORT} --host 0.0.0.0\"/" /usr/local/lib/node_modules/vroom-express/package.json
fi

# Hand off to upstream entrypoint via bash (ensure no exec bit needed)
exec /bin/bash /docker-entrypoint.sh
