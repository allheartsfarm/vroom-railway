FROM --platform=linux/amd64 vroomvrp/vroom-docker:v1.9.0

# Custom entrypoint to render config.yml from env and start vroom-express
COPY scripts/entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh

# Set environment variables for OSRM
ENV VROOM_ROUTER=osrm

EXPOSE 8080
CMD ["/railway-entrypoint.sh"]

