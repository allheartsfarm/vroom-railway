FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Install Node.js for our proxy server
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && update-ca-certificates || true \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./
RUN npm install

# Copy proxy server
COPY server.js ./

# Set environment variables
ENV VROOM_ROUTER=valhalla \
    VROOM_LOG=/conf \
    # Use Valhalla public URL to avoid internal networking issues
    VALHALLA_HOST=allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 3000

# Start the proxy server
CMD ["npm", "start"]

