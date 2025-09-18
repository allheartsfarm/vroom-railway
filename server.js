import express from "express";
import { createProxyMiddleware } from "http-proxy-middleware";
import { spawn } from "child_process";
import { writeFileSync } from "fs";
import { setDefaultResultOrder } from "dns";

// Prefer IPv4 to avoid IPv6-only egress issues in some environments
setDefaultResultOrder("ipv4first");

const app = express();
const port = process.env.PORT || 3000;

// Generate vroom config.yml
const generateVroomConfig = () => {
  const rawHost =
    process.env.VALHALLA_HOST || "allheartsfarm-valhalla.up.railway.app";
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
    car:
      host: '${sanitizedHost}'
      port: '${port}'
      use_https: ${useHttps}
    bike:
      host: '${sanitizedHost}'
      port: '${port}'
      use_https: ${useHttps}
    foot:
      host: '${sanitizedHost}'
      port: '${port}'
      use_https: ${useHttps}
    auto:
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

  writeFileSync("/tmp/vroom-config.yml", config);
  console.log("Generated vroom config:", config);
};

// Start vroom in background
let vroomProcess;
const startVroom = () => {
  console.log("Starting vroom...");
  generateVroomConfig();

  // Start vroom on port 8080
  vroomProcess = spawn("vroom", ["--router", "valhalla", "--port", "8080"], {
    stdio: "inherit",
    env: {
      ...process.env,
      PORT: "8080",
      VROOM_ROUTER: "valhalla",
      VROOM_VALHALLA_HOST:
        process.env.VALHALLA_HOST || "allheartsfarm-valhalla.up.railway.app",
      VROOM_VALHALLA_PORT: process.env.VALHALLA_PORT || "443",
      VROOM_VALHALLA_USE_HTTPS: process.env.VALHALLA_USE_HTTPS || "true",
    },
  });

  vroomProcess.on("error", (err) => {
    console.error("Failed to start vroom:", err);
  });

  vroomProcess.on("exit", (code) => {
    console.log("vroom exited with code:", code);
  });
};

// Health endpoint
app.get("/health", (req, res) => {
  res.json({
    ok: true,
    port,
    vroom_router: process.env.VROOM_ROUTER || "valhalla",
    valhalla_host: (
      process.env.VALHALLA_HOST || "allheartsfarm-valhalla.up.railway.app"
    )
      .replace(/^https?:\/\//i, "")
      .replace(/\/$/, ""),
    valhalla_use_https:
      String(process.env.VALHALLA_USE_HTTPS || "true").toLowerCase() === "true",
    valhalla_port: process.env.VALHALLA_PORT || "443",
  });
});

// Proxy all other requests to vroom-express
const vroomProxy = createProxyMiddleware({
  target: "http://localhost:8080",
  changeOrigin: true,
  timeout: 30000,
  onError: (err, req, res) => {
    console.error("Proxy error:", err);
    res
      .status(502)
      .json({ error: "Vroom service unavailable", message: err.message });
  },
});

app.use("/", vroomProxy);

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("Shutting down...");
  if (vroomProcess) {
    vroomProcess.kill();
  }
  process.exit(0);
});

// Start services
console.log(`Starting proxy server on port ${port}`);
console.log(
  `Environment: VROOM_ROUTER=${process.env.VROOM_ROUTER}, VALHALLA_HOST=${process.env.VALHALLA_HOST}`
);

// Wait a moment then start vroom
setTimeout(startVroom, 2000);

app.listen(port, "0.0.0.0", () => {
  console.log(`Vroom proxy listening on 0.0.0.0:${port}`);
});
