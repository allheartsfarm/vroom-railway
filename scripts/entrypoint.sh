#!/usr/bin/env bash
set -e

# Debug: Show environment
echo "=== ENVIRONMENT DEBUG ==="
echo "PORT: ${PORT:-not set}"
echo "VROOM_ROUTER: ${VROOM_ROUTER:-not set}"
echo "=========================="

# Defaults
PORT=${PORT:-8080}
VROOM_ROUTER=${VROOM_ROUTER:-osrm}
VROOM_LOG=${VROOM_LOG:-/conf}

mkdir -p /conf

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
YAML

# Log the effective config for troubleshooting
echo "=== RENDERED /conf/config.yml ==="
cat /conf/config.yml || true
echo "=================================="

# Ensure access.log exists for vroom-express
touch /conf/access.log

# Hand off to upstream entrypoint which starts vroom-express
exec /bin/bash /docker-entrypoint.sh
