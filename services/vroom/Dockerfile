  FROM --platform=linux/amd64 gis-ops/vroom-docker:latest

# Copy custom entrypoint with Valhalla configuration
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables for Valhalla routing
ENV PORT=8080 \
    VROOM_ROUTER=valhalla \
    VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 8080
CMD ["/entrypoint.sh"]