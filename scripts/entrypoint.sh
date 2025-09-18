#!/usr/bin/env bash
set -e

echo "Starting VROOM with OSRM configuration..."

# Defaults
PORT=${PORT:-8080}
VROOM_ROUTER=${VROOM_ROUTER:-osrm}

mkdir -p /conf

# Generate config for OSRM
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
  osrm:
    car:
      - host: 'localhost'
        port: 5000
    bike:
      - host: 'localhost'
        port: 5000
    foot:
      - host: 'localhost'
        port: 5000
YAML

echo "=== RENDERED /conf/config.yml ==="
cat /conf/config.yml
echo "=================================="

# Hand off to upstream entrypoint which starts vroom-express
exec /bin/bash /docker-entrypoint.sh
