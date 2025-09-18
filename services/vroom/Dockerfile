  FROM --platform=linux/amd64 ghcr.io/vroom-project/vroom-docker:v1.14.0

# Copy custom entrypoint for Valhalla configuration
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables for OSRM
ENV VROOM_ROUTER=osrm \
    VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 8080
CMD ["/entrypoint.sh"]