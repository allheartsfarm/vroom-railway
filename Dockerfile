FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Custom entrypoint writes /conf/config.yml from env, then calls upstream entrypoint
COPY scripts/entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

ENV VROOM_ROUTER=valhalla \
    VROOM_LOG=/conf \
    FORCE_CONFIG_REWRITE=1 \
    # Use Valhalla public URL to avoid internal networking issues
    VALHALLA_HOST=https://allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT= \
    OSRM_HOST=osrm \
    OSRM_PORT=5000 \
    ORS_HOST=ors \
    ORS_PORT=8080

EXPOSE 3000
CMD ["/railway-entrypoint.sh"]

