#!/usr/bin/env bash
set -euo pipefail

# Defaults (can be overridden by env)
PORT=${PORT:-3000}
VROOM_ROUTER=${VROOM_ROUTER:-osrm}
VROOM_LOG=${VROOM_LOG:-/conf}

VALHALLA_HOST=${VALHALLA_HOST:-valhalla}
VALHALLA_PORT=${VALHALLA_PORT:-8002}

OSRM_HOST=${OSRM_HOST:-osrm}
OSRM_PORT=${OSRM_PORT:-5000}

ORS_HOST=${ORS_HOST:-ors}
ORS_PORT=${ORS_PORT:-8080}

mkdir -p /conf

# Only (re)write config if none present, so you can tweak in container
if [[ ! -f /conf/config.yml ]]; then
  cat > /conf/config.yml <<YAML
router: ${VROOM_ROUTER}
port: ${PORT}
routingServers:
  osrm:
    car:   { host: "${OSRM_HOST}", port: ${OSRM_PORT} }
    bike:  { host: "${OSRM_HOST}", port: ${OSRM_PORT} }
    foot:  { host: "${OSRM_HOST}", port: ${OSRM_PORT} }
  valhalla:
    car:   { host: "${VALHALLA_HOST}", port: ${VALHALLA_PORT} }
    bike:  { host: "${VALHALLA_HOST}", port: ${VALHALLA_PORT} }
    foot:  { host: "${VALHALLA_HOST}", port: ${VALHALLA_PORT} }
  ors:
    car:   { host: "${ORS_HOST}", port: ${ORS_PORT} }
    bike:  { host: "${ORS_HOST}", port: ${ORS_PORT} }
    foot:  { host: "${ORS_HOST}", port: ${ORS_PORT} }
YAML
fi

# Ensure access.log exists for vroom-express
touch /conf/access.log

# Hand off to upstream entrypoint via bash (ensure no exec bit needed)
exec /bin/bash /docker-entrypoint.sh
