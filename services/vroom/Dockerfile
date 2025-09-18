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
ENV VROOM_ROUTER=osrm

EXPOSE 8080
CMD ["node", "server.js"]

