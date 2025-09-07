import { createServer } from "vroom-express";

const app = await createServer();

// Railway sets PORT at runtime - this is critical!
const port = process.env.PORT ? Number(process.env.PORT) : 3000;
const host = "0.0.0.0"; // Use IPv4 only, avoid IPv6

console.log(`Railway PORT: ${process.env.PORT}`);
console.log(`Using port: ${port}`);
console.log(`Using host: ${host}`);

// Add health endpoint
app.get("/health", (_, res) =>
  res.json({ ok: true, port, host, railway_port: process.env.PORT })
);

// Start server on Railway's PORT
app.listen(port, host, () => {
  console.log(`vroom-express listening on ${host}:${port}`);
  console.log(`Health check: http://${host}:${port}/health`);
});
