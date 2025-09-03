Railway deployment for VROOM (vroom-express) + OSRM

Overview
- Two services:
  - osrm: Prepares OSM data and runs `osrm-routed`.
  - vroom: Runs `vroom-express` and connects to OSRM.

Requirements
- Railway CLI installed and logged in: `npm i -g @railway/cli && railway login`.
- Choose a small PBF to start (e.g. Liechtenstein) to keep resources light.

Environment variables
- OSRM service:
  - `PBF_URL` (required): URL to .osm.pbf (e.g. https://download.geofabrik.de/europe/liechtenstein-latest.osm.pbf)
  - `OSRM_PROFILE` (optional): `car|bike|foot` (default `car`).
  - `OSRM_ALGORITHM` (optional): `mld|ch` (default `mld`).
  - `OSRM_PORT` (optional): listen port (default `5000`).
- VROOM service:
  - `OSRM_URL` (required): Base URL for OSRM (e.g. OSRM service public URL or internal URL).
  - `VROOM_ROUTER` (optional): `osrm|valhalla|ors` (default `osrm`).
  - `PORT` (optional): vroom-express HTTP port (Railway often sets this; default `3000`).

Deploy steps
1) Initialize Railway project (root):
   - `railway init`

2) Deploy OSRM service:
   - `cd services/osrm`
   - `railway up`
   - When prompted, create a new service named `osrm`.
   - In the Railway dashboard, set env vars for `osrm`:
     - `PBF_URL` to your chosen dataset
     - Optionally `OSRM_PROFILE`, `OSRM_ALGORITHM`, `OSRM_PORT`
   - Wait for deploy; confirm it serves `/route` on `:<OSRM_PORT>`.

3) Deploy VROOM service:
   - `cd ../vroom`
   - `railway up`
   - Create a new service named `vroom`.
   - Set env vars for `vroom`:
     - `OSRM_URL` to the OSRM service URL, e.g. the public URL of the `osrm` service (http://<osrm-domain>:<port>)
     - Optionally `VROOM_ROUTER=osrm` and `PORT` if needed
   - After deploy, hit `GET /health` on the vroom service to verify.

Notes
- If you enable private networking in Railway, you can use the internal service URL for `OSRM_URL` instead of the public domain.
- OSRM extraction can be CPU/memory intensive; start with a very small PBF.
- The `osrm` service stores data in the container FS; for persistence across deploys, consider adding a Railway Volume and set `DATA_DIR` accordingly (edit start script and Dockerfile if you do so).

