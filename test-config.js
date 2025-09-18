#!/usr/bin/env node

// Test script to verify Vroom configuration
import { writeFileSync } from "fs";

// Generate the same config that the server would generate
const generateVroomConfig = () => {
  const rawHost = process.env.VALHALLA_HOST || "allheartsfarm-valhalla.up.railway.app";
  const sanitizedHost = rawHost.replace(/^https?:\/\//i, "").replace(/\/$/, "");
  const useHttps =
    String(process.env.VALHALLA_USE_HTTPS || "true").toLowerCase() === "true";
  const port = process.env.VALHALLA_PORT || "443";
  const router = process.env.VROOM_ROUTER || "valhalla";
  
  let config;
  if (router === "valhalla") {
    config = `# Vroom configuration for Valhalla routing
cliArgs:
  router: 'valhalla'
  port: 8080
  geometry: true

routingServers:
  valhalla:
    host: '${sanitizedHost}'
    port: '${port}'
    use_https: ${useHttps}
`;
  } else {
    config = `# Vroom configuration for OSRM routing
vroom:
  router: osrm
  geometry: true
  
routing:
  osrm:
    servers:
      - host: localhost
        port: 5000
`;
  }

  return config;
};

console.log("=== VROOM CONFIGURATION TEST ===");
console.log("Environment variables:");
console.log("VROOM_ROUTER:", process.env.VROOM_ROUTER || "valhalla");
console.log("VALHALLA_HOST:", process.env.VALHALLA_HOST || "allheartsfarm-valhalla.up.railway.app");
console.log("VALHALLA_PORT:", process.env.VALHALLA_PORT || "443");
console.log("VALHALLA_USE_HTTPS:", process.env.VALHALLA_USE_HTTPS || "true");
console.log("\nGenerated config:");
console.log(generateVroomConfig());

// Write config to file for testing
writeFileSync("/tmp/test-vroom-config.yml", generateVroomConfig());
console.log("\nConfig written to /tmp/test-vroom-config.yml");
