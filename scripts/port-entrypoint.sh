#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla routing on port ${PORT:-8080}..."

# Set environment variables for Valhalla routing
export VROOM_ROUTER=valhalla
export VROOM_VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
export VROOM_VALHALLA_PORT=443
export PORT=${PORT:-8080}

echo "=== ENVIRONMENT VARIABLES ==="
echo "VROOM_ROUTER: $VROOM_ROUTER"
echo "VROOM_VALHALLA_HOST: $VROOM_VALHALLA_HOST"
echo "VROOM_VALHALLA_PORT: $VROOM_VALHALLA_PORT"
echo "PORT: $PORT"
echo "============================="

# Ensure config dir exists
mkdir -p /conf

# Start lightweight HTTPS→HTTP proxy to Valhalla (listens on 9002)
export TARGET_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
export TARGET_PORT=${VALHALLA_PORT:-443}
node /proxy.js &

# Write vroom-express configuration to /conf/config.yml pointing to local proxy
cat > /conf/config.yml << EOF
cliArgs:
  host: '0.0.0.0'
  port: $PORT
  router: 'valhalla'
  geometry: true
  baseurl: '/'
  logdir: '/conf'
  logsize: '100M'
  limit: '1mb'
  path: ''

routingServers:
  valhalla:
    car:
      host: '127.0.0.1'
      port: 9002
      use_https: false
    bike:
      host: '127.0.0.1'
      port: 9002
      use_https: false
    foot:
      host: '127.0.0.1'
      port: 9002
      use_https: false
    auto:
      host: '127.0.0.1'
      port: 9002
      use_https: false
EOF

echo "=== Generated /conf/config.yml ==="
cat /conf/config.yml

# Start vroom-express with explicit config
exec vroom-express --config /conf/config.yml --port $PORT
