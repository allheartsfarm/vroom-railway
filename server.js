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
  const rawHost = process.env.VALHALLA_HOST || "valhalla";
  const sanitizedHost = rawHost.replace(/^https?:\/\//i, "").replace(/\/$/, "");
  const useHttps =
    String(process.env.VALHALLA_USE_HTTPS || "false").toLowerCase() === "true";
  const port = process.env.VALHALLA_PORT || (useHttps ? "443" : "8080");
  const config = `# Vroom configuration
vroom:
  router: ${process.env.VROOM_ROUTER || "osrm"}
  geometry: true
  
routing:
  osrm:
    servers:
      - host: localhost
        port: 5000
`;

  writeFileSync("/tmp/vroom-config.yml", config);
  console.log("Generated vroom config:", config);
};

// Start vroom-express in background
let vroomProcess;
const startVroom = () => {
  console.log("Starting vroom-express...");
  generateVroomConfig();

  // Start vroom-express on port 8080
  vroomProcess = spawn(
    "vroom-express",
    ["--config", "/tmp/vroom-config.yml", "--port", "8080"],
    {
      stdio: "inherit",
      env: { ...process.env, PORT: "8080" },
    }
  );

  vroomProcess.on("error", (err) => {
    console.error("Failed to start vroom-express:", err);
  });

  vroomProcess.on("exit", (code) => {
    console.log("vroom-express exited with code:", code);
  });
};

// Health endpoint
app.get("/health", (req, res) => {
  res.json({
    ok: true,
    port,
    vroom_router: process.env.VROOM_ROUTER || "osrm",
    valhalla_host: (process.env.VALHALLA_HOST || "valhalla")
      .replace(/^https?:\/\//i, "")
      .replace(/\/$/, ""),
    valhalla_use_https:
      String(process.env.VALHALLA_USE_HTTPS || "false").toLowerCase() ===
      "true",
    valhalla_port:
      process.env.VALHALLA_PORT ||
      (String(process.env.VALHALLA_USE_HTTPS || "false").toLowerCase() ===
      "true"
        ? "443"
        : "8080"),
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
