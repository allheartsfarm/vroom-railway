FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Install Node.js and npm
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

# Copy the server.js file
COPY server.js /app/server.js
COPY package.json /app/package.json

# Install dependencies
WORKDIR /app
RUN npm install

# Set environment variables
ENV VROOM_ROUTER=valhalla \
    VALHALLA_HOST=valhalla \
    VALHALLA_PORT=8080 \
    VALHALLA_USE_HTTPS=false

EXPOSE 8080
CMD ["node", "server.js"]

