FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Custom entrypoint to render config.yml from env and start vroom-express
COPY scripts/entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

ENV VROOM_ROUTER=valhalla \
    VROOM_LOG=/conf \
    VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 8080
CMD ["/railway-entrypoint.sh"]

