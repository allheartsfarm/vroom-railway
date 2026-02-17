FROM --platform=linux/amd64 ghcr.io/vroom-project/vroom-docker:v1.14.0

# Copy proxy and entrypoint
COPY scripts/proxy.js /proxy.js
COPY scripts/front-proxy.js /front-proxy.js
COPY scripts/port-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ensure Node.js is available for the local HTTPS→HTTP proxy on :9002
# Using NodeSource setup for Node 18 (LTS compatible with our proxy)
RUN apt-get update \
    && apt-get install -y curl ca-certificates gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Environment
ENV PORT=8080 \
    VROOM_ROUTER=valhalla \
    VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443

EXPOSE 8080
CMD ["/entrypoint.sh"]