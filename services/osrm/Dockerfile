FROM ghcr.io/project-osrm/osrm-backend:latest

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Defaults; can be overridden in Railway env
ENV OSRM_PROFILE=car \
    OSRM_ALGORITHM=mld \
    OSRM_PORT=5000 \
    DATA_DIR=/data \
    PBF_URL=""

EXPOSE 5000
CMD ["/start.sh"]

