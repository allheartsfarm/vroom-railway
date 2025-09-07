FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY src/ ./src/

# Create config directory
RUN mkdir -p /conf

# Set environment variables
ENV VROOM_ROUTER=valhalla \
    VROOM_LOG=/conf \
    # Use Valhalla public URL to avoid internal networking issues
    VALHALLA_HOST=https://allheartsfarm-valhalla.up.railway.app \
    VALHALLA_PORT=443 \
    VALHALLA_USE_HTTPS=true

EXPOSE 3000

# Start the custom vroom server
CMD ["npm", "start"]

