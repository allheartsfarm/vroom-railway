#!/usr/bin/env bash
set -euo pipefail

OSRM_PROFILE=${OSRM_PROFILE:-car}
OSRM_ALGORITHM=${OSRM_ALGORITHM:-mld}
OSRM_PORT=${OSRM_PORT:-5000}
DATA_DIR=${DATA_DIR:-/data}
PBF_URL=${PBF_URL:-}

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

if [[ -z "$PBF_URL" ]]; then
  echo "ERROR: PBF_URL is not set. Provide a small .osm.pbf to start (e.g. geofabrik URL)." >&2
  exit 1
fi

PBF_FILE="${DATA_DIR}/map.osm.pbf"
OSRM_BASENAME="${DATA_DIR}/map.osrm"

if [[ ! -f "$PBF_FILE" ]]; then
  echo "Downloading OSM PBF from $PBF_URL ..."
  curl -L "$PBF_URL" -o "$PBF_FILE"
fi

PROFILE_PATH="/opt/${OSRM_PROFILE}.lua"
if [[ ! -f "$PROFILE_PATH" ]]; then
  # Default profile locations in the osrm-backend image
  PROFILE_PATH="/opt/${OSRM_PROFILE}.lua"
fi

# (Re)build if no dataset present
if [[ ! -f "${OSRM_BASENAME}" ]]; then
  echo "Extracting with profile ${OSRM_PROFILE} ..."
  osrm-extract -p "$PROFILE_PATH" "$PBF_FILE"

  if [[ "$OSRM_ALGORITHM" == "mld" ]]; then
    echo "Partitioning (MLD) ..."
    osrm-partition "${OSRM_BASENAME}"
    echo "Customizing (MLD) ..."
    osrm-customize "${OSRM_BASENAME}"
  fi
fi

echo "Starting osrm-routed on port ${OSRM_PORT} (algorithm: ${OSRM_ALGORITHM}) ..."
exec osrm-routed --algorithm "$OSRM_ALGORITHM" -p "$OSRM_PORT" "${OSRM_BASENAME}"

