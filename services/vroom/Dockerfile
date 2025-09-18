FROM --platform=linux/amd64 ghcr.io/vroom-project/vroom-docker:latest

# Copy proxy and entrypoint
COPY scripts/proxy.js /proxy.js
COPY scripts/port-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Environment
ENV PORT=8080 \
    VROOM_ROUTER=valhalla \
    VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443

EXPOSE 8080
CMD ["/entrypoint.sh"]