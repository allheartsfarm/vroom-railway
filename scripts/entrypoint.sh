#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla routing..."

# Set environment variables for Valhalla
export VROOM_ROUTER=valhalla
export VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
export VALHALLA_PORT=443
export VALHALLA_USE_HTTPS=${VALHALLA_USE_HTTPS:-true}
export PORT=${PORT:-8080}

echo "=== ENVIRONMENT VARIABLES ==="
echo "VROOM_ROUTER: $VROOM_ROUTER"
echo "VALHALLA_HOST: $VALHALLA_HOST"
echo "VALHALLA_PORT: $VALHALLA_PORT"
echo "VALHALLA_USE_HTTPS: $VALHALLA_USE_HTTPS"
echo "PORT: $PORT"
echo "============================="

# Create config directory and file
mkdir -p /conf

# Create a simple VROOM configuration
cat > /conf/config.yml <<EOF
cliArgs:
  geometry: true
  planmode: false
  threads: 8
  explore: 5
  limit: '20mb'
  logdir: '/conf'
  logsize: '100M'
  maxlocations: 1000
  maxvehicles: 200
  override: true
  path: ''
  host: '0.0.0.0'
  port: ${PORT}
  router: 'valhalla'
  timeout: 300000
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
    truck:
      host: '${VALHALLA_HOST}'
      port: ${VALHALLA_PORT}
      use_https: ${VALHALLA_USE_HTTPS}
EOF

echo "=== VROOM CONFIG ==="
cat /conf/config.yml
echo "===================="

# Start vroom-express with proper permissions
chmod +x /usr/local/bin/vroom-express 2>/dev/null || true
exec /usr/local/bin/vroom-express 