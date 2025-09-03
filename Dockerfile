FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Custom entrypoint writes /conf/config.yml from env, then calls upstream entrypoint
COPY scripts/entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

ENV PORT=3000 \
    VROOM_ROUTER=osrm \
    VROOM_LOG=/conf \
    # Default internal hosts for Railway services
    VALHALLA_HOST=valhalla \
    VALHALLA_PORT=8080 \
    OSRM_HOST=osrm \
    OSRM_PORT=5000 \
    ORS_HOST=ors \
    ORS_PORT=8080

EXPOSE 3000
CMD ["/railway-entrypoint.sh"]

