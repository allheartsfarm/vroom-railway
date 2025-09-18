FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

EXPOSE 8080
CMD ["/bin/bash", "-c", "which vroom-express || find / -name '*vroom*' -type f 2>/dev/null | head -10; exec vroom-express"]

