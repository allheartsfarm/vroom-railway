#!/usr/bin/env bash
set -euo pipefail

# Defaults (can be overridden by env)
PORT=${PORT:-3000}
# Force Valhalla router to avoid OSRM fallback when env is misconfigured
VROOM_ROUTER=valhalla
export VROOM_ROUTER=valhalla
VROOM_LOG=${VROOM_LOG:-/conf}

# Sanitize Valhalla host and normalize HTTPS/port
RAW_VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
VALHALLA_HOST_CLEAN=${RAW_VALHALLA_HOST#http://}
VALHALLA_HOST_CLEAN=${VALHALLA_HOST_CLEAN#https://}
VALHALLA_HOST_CLEAN=${VALHALLA_HOST_CLEAN%/}
  # Use hostname for SSL certificate validation
VALHALLA_HOST_CLEAN=allheartsfarm-valhalla.up.railway.app
# Use HTTPS on port 443
VALHALLA_USE_HTTPS_NORM=true
VALHALLA_PORT_EFF=443

# Remove OSRM/ORS defaults to force Valhalla usage

mkdir -p /conf

# Always force config regeneration on each boot
rm -f /conf/config.yml /vroom/config.yml /etc/vroom/config.yml 2>/dev/null || true

# Always (re)write config on boot so current env is applied
# Remove any existing config first
rm -f /conf/config.yml /vroom/config.yml /etc/vroom/config.yml 2>/dev/null || true

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
  router: 'valhalla'
  timeout: 10000
  baseurl: '/'
routingServers:
  valhalla:
    car:
      host: 'allheartsfarm-valhalla.up.railway.app'
      port: 8080
      use_https: false
    bike:
      host: 'allheartsfarm-valhalla.up.railway.app'
      port: 8080
      use_https: false
    foot:
      host: 'allheartsfarm-valhalla.up.railway.app'
      port: 8080
      use_https: false
    auto:
      host: 'allheartsfarm-valhalla.up.railway.app'
      port: 8080
      use_https: false
YAML

# Log the effective config for troubleshooting
echo "=== RENDERED /conf/config.yml ==="
sed -e 's/^/  /' /conf/config.yml || true
echo "=================================="

# Ensure access.log exists for vroom-express
touch /conf/access.log

# Ensure vroom-express uses Railway's $PORT if provided; default 8080
export PORT=${PORT:-8080}

# Debug: Show what we're using for Valhalla
echo "=== VROOM CONFIG DEBUG ==="
echo "VROOM_ROUTER: $VROOM_ROUTER"
echo "VALHALLA_HOST (raw): $RAW_VALHALLA_HOST"
echo "VALHALLA_HOST (clean): $VALHALLA_HOST_CLEAN"
echo "VALHALLA_PORT (effective): $VALHALLA_PORT_EFF"
echo "VALHALLA_USE_HTTPS (normalized): $VALHALLA_USE_HTTPS_NORM"
echo "PORT: $PORT"
echo "=========================="

# The original vroom-express is hardcoded to port 8080, so we need to ensure
# Railway's edge proxy can reach it. Since we set PORT=8080 in Railway env vars,
# this should work.

# Hand off to upstream entrypoint which starts vroom-express; it will
# pick up /conf/config.yml if present.
exec /bin/bash /docker-entrypoint.sh
