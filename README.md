# VROOM on Railway (Valhalla-ready)

This repo builds a container for `vroom-express` and renders a `config.yml` from environment variables. It is preconfigured to talk to a Valhalla service on Railway via private networking.

## Quick Start

1) Install Railway CLI and login
- `npm i -g @railway/cli`
- `railway login`

2) Deploy this service
- `railway up`
- Create/select a service, name it for example `vroom`.

3) Set environment variables in Railway (Variables tab)
- `VROOM_ROUTER=valhalla`
- `VALHALLA_HOST=valhalla`  (private DNS of your Valhalla service)
- `VALHALLA_PORT=8002`
- Optional: leave `PORT` unset so Railway injects it; otherwise set `PORT=3000`.

4) Redeploy and test
- Health: `curl -sSf https://<your-vroom-domain>/health`
- Solve via Valhalla:
  `curl -sS -X POST https://<your-vroom-domain>/ -H 'Content-Type: application/json' -d '{"vehicles":[{"id":1,"profile":"car","start":[13.38886,52.51703],"end":[13.39763,52.52941]}],"jobs":[{"id":1,"location":[13.405,52.52]},{"id":2,"location":[13.39,52.51]}]}'`

## Notes
- The image is based on `ghcr.io/vroom-project/vroom-docker:v1.14.0`.
- The entrypoint writes `/conf/config.yml` from env, then uses the upstream entrypoint to start `vroom-express`.
- To use OSRM instead, set `VROOM_ROUTER=osrm` and provide `OSRM_HOST`/`OSRM_PORT`.
- To use ORS, set `VROOM_ROUTER=ors` and provide `ORS_HOST`/`ORS_PORT`.
- You can override any env defined in `.env.example`.

## Troubleshooting
- "Invalid profile: car": the selected `VROOM_ROUTER` has no reachable server configured. Ensure host/port envs point to a live service and redeploy.
- Matrix mode works without any router. Example:
  `curl -sS -X POST https://<your-vroom-domain>/ -H 'Content-Type: application/json' -d '{"vehicles":[{"id":1,"start_index":0,"end_index":0}],"jobs":[{"id":1,"location_index":1},{"id":2,"location_index":2}],"matrix":[[0,10,20],[10,0,15],[20,15,0]]}'`

