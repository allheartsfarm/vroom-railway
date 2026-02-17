const http = require("http");
const https = require("https");
const { URL } = require("url");

const TARGET_HOST =
  process.env.TARGET_HOST || "allheartsfarm-valhalla.up.railway.app";
const TARGET_PORT = parseInt(process.env.TARGET_PORT || "443", 10);
const LISTEN_PORT = parseInt(process.env.PROXY_PORT || "9002", 10);

const server = http.createServer((clientReq, clientRes) => {
  const chunks = [];
  clientReq.on("data", (c) => chunks.push(c));
  clientReq.on("end", () => {
    let body = Buffer.concat(chunks);

    // If JSON body, rewrite Valhalla costing values (car->auto, bike->bicycle, foot->pedestrian)
    const ct = (clientReq.headers["content-type"] || "").toLowerCase();
    if (ct.includes("application/json") && body.length) {
      try {
        const json = JSON.parse(body.toString("utf8"));
        if (typeof json === "object" && json) {
          const map = {
            car: process.env.CAR_COSTING || "auto",
            bike: process.env.BIKE_COSTING || "bicycle",
            foot: process.env.FOOT_COSTING || "pedestrian",
            truck: process.env.TRUCK_COSTING || "truck",
          };
          if (
            json.costing &&
            typeof json.costing === "string" &&
            map[json.costing]
          ) {
            json.costing = map[json.costing];
          }
          // Some payloads nest profile/costing per shipment; keep simple for now
          const rewritten = JSON.stringify(json);
          body = Buffer.from(rewritten, "utf8");
        }
      } catch (_) {
        // ignore parse errors and forward as-is
      }
    }

    // Also handle GET/POST with query param ?json=... (Valhalla style)
    let path = clientReq.url;
    try {
      const u = new URL(clientReq.url, `http://localhost`);
      const jsonParam = u.searchParams.get("json");
      if (jsonParam) {
        const parsed = JSON.parse(jsonParam);
        const map = {
          car: process.env.CAR_COSTING || "auto",
          bike: process.env.BIKE_COSTING || "bicycle",
          foot: process.env.FOOT_COSTING || "pedestrian",
          truck: process.env.TRUCK_COSTING || "truck",
        };
        if (
          parsed &&
          typeof parsed === "object" &&
          typeof parsed.costing === "string" &&
          map[parsed.costing]
        ) {
          parsed.costing = map[parsed.costing];
          u.searchParams.set("json", JSON.stringify(parsed));
          path = u.pathname + "?" + u.searchParams.toString();
        }
      }
    } catch (_) {}

    const headers = { ...clientReq.headers, host: TARGET_HOST };
    if (body.length) headers["content-length"] = Buffer.byteLength(body);

    const reqStart = Date.now();
    const options = {
      hostname: TARGET_HOST,
      port: TARGET_PORT,
      path,
      method: clientReq.method,
      headers,
    };

    const proxyReq = https.request(options, (proxyRes) => {
      const status = proxyRes.statusCode || 0;
      const chunksOut = [];
      proxyRes.on("data", (c) => chunksOut.push(c));
      if (!clientRes.headersSent) {
        clientRes.writeHead(status, proxyRes.headers);
      }
      proxyRes.on("end", () => {
        const buf = Buffer.concat(chunksOut);
        console.log(
          JSON.stringify({
            event: "proxy_response",
            method: clientReq.method,
            path,
            to: `${TARGET_HOST}:${TARGET_PORT}`,
            status,
            ms: Date.now() - reqStart,
            preview: buf.toString("utf8").slice(0, 200),
          })
        );
        if (!clientRes.writableEnded) clientRes.end(buf);
      });
    });

    // Guard against upstream errors after response started
    proxyReq.on("error", (err) => {
      try {
        if (!clientRes.headersSent && !clientRes.writableEnded) {
          clientRes.statusCode = 502;
          clientRes.setHeader("content-type", "application/json");
          clientRes.end(
            JSON.stringify({ error: "proxy_error", message: err.message })
          );
        } else if (!clientRes.writableEnded) {
          clientRes.end();
        }
      } catch (_) {}
      console.log(
        JSON.stringify({
          event: "proxy_error",
          method: clientReq.method,
          path,
          to: `${TARGET_HOST}:${TARGET_PORT}`,
          message: err.message,
        })
      );
    });

    // Timeout and client abort handling
    proxyReq.setTimeout(15000, () => {
      proxyReq.destroy(new Error("upstream_timeout"));
    });
    clientReq.on("aborted", () => {
      try {
        proxyReq.destroy(new Error("client_aborted"));
      } catch (_) {}
    });

    if (body.length > 0) proxyReq.write(body);
    proxyReq.end();
  });
});

server.listen(LISTEN_PORT, "0.0.0.0", () => {
  console.log(
    `valhalla https proxy listening on 0.0.0.0:${LISTEN_PORT} → https://${TARGET_HOST}:${TARGET_PORT}`
  );
});
