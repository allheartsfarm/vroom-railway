#!/usr/bin/env bash
set -e

echo "Starting VROOM with Valhalla routing on port ${PORT:-8080}..."

# Set environment variables for Valhalla routing
export VROOM_ROUTER=valhalla
export VROOM_VALHALLA_HOST=${VALHALLA_HOST:-allheartsfarm-valhalla.up.railway.app}
export VROOM_VALHALLA_PORT=${VALHALLA_PORT:-443}
export PORT=${PORT:-8080}

echo "=== ENVIRONMENT VARIABLES ==="
echo "VROOM_ROUTER: $VROOM_ROUTER"
echo "VROOM_VALHALLA_HOST: $VROOM_VALHALLA_HOST"
echo "VROOM_VALHALLA_PORT: $VROOM_VALHALLA_PORT"
echo "PORT: $PORT"
echo "============================="

# Start vroom with Valhalla routing using environment variables
exec vroom --router valhalla --port $PORT
