FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Custom entrypoint to render config.yml from env and start vroom-express
COPY scripts/entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

ENV VROOM_ROUTER=valhalla \
    VROOM_LOG=/conf \
    VALHALLA_HOST=valhalla \
    VALHALLA_PORT=8080 \
    VALHALLA_USE_HTTPS=false \
    PORT=8080

EXPOSE 8080
CMD ["/railway-entrypoint.sh"]

