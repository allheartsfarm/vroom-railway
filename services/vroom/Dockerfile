FROM --platform=linux/amd64 node:18-alpine

# Install VROOM dependencies
RUN apk add --no-cache curl

# Copy the server.js file
COPY server.js /app/server.js
COPY package.json /app/package.json

# Install dependencies
WORKDIR /app
RUN npm install

# Set environment variables for Valhalla
ENV VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 8080
CMD ["node", "server.js"]