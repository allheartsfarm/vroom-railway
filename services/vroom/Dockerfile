FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Custom entrypoint to render config.yml from env and start vroom-express
COPY entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

ENV PORT=3000 \
    VROOM_ROUTER=osrm \
    VROOM_LOG=/conf \
    OSRM_URL="" \
    OSRM_HOST="" \
    OSRM_PORT="" \
    OSRM_PROFILE=car

EXPOSE 3000
CMD ["/railway-entrypoint.sh"]

