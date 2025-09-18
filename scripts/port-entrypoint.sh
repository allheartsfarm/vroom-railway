#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla routing on port ${PORT:-8080}..."

# Set environment variables for Valhalla routing
export VROOM_ROUTER=valhalla
export VROOM_VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
export VROOM_VALHALLA_PORT=443
# Prefer platform-provided dynamic port if present
export PORT=${PORT:-${RAILWAY_TCP_PORT:-8080}}

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
  port: $PORT
  router: 'valhalla'
  timeout: 30000
  baseurl: '/'

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

# Make config available where vroom-express expects it and start
ln -sf /conf/config.yml /vroom-express/config.yml
exec node /vroom-express/src/index.js
