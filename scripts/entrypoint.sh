#!/usr/bin/env bash
set -e

echo "Starting VROOM with default configuration..."

# Hand off to upstream entrypoint which starts vroom-express
exec /bin/bash /docker-entrypoint.sh
