FROM --platform=linux/amd64 ghcr.io/vroom-project/vroom-docker:latest

# Copy simple entrypoint
COPY scripts/port-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables for Valhalla routing
ENV PORT=8080 \
    VROOM_ROUTER=valhalla \
    VROOM_VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VROOM_VALHALLA_PORT=443 \
    VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 8080
CMD ["/entrypoint.sh"]