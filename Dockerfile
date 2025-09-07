FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# FORCE DOCKER BUILD - Railway should use this Dockerfile
# Cache bust - force rebuild v3
# Custom entrypoint writes /conf/config.yml from env, then calls upstream entrypoint
COPY scripts/entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

ENV VROOM_ROUTER=valhalla \
    VROOM_LOG=/conf \
    FORCE_CONFIG_REWRITE=1 \
    # Use Valhalla public URL to avoid internal networking issues
    VALHALLA_HOST=https://allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 8080

# Use our custom entrypoint to generate config.yml
CMD ["/railway-entrypoint.sh"]

