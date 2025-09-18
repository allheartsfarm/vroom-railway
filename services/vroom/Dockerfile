FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Custom entrypoint to render config.yml from env and start vroom-express
COPY scripts/entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

# Ensure HTTPS to external services works (install CA roots) on Debian/Alpine
RUN set -eux; \
  if command -v apk >/dev/null 2>&1; then \
    apk add --no-cache ca-certificates; \
    update-ca-certificates; \
  else \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    update-ca-certificates || true; \
  fi

ENV VROOM_ROUTER=osrm \
    VROOM_LOG=/conf \
    OSRM_URL="" \
    OSRM_HOST="" \
    OSRM_PORT="" \
    OSRM_PROFILE=car

# Prefer IPv4 when both A/AAAA exist (avoids IPv6-only egress issues)
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

EXPOSE 8080
CMD ["/railway-entrypoint.sh"]

