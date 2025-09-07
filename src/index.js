import { createServer } from "vroom-express";

const app = await createServer();

// Railway sets PORT at runtime
const port = process.env.PORT ? Number(process.env.PORT) : 3000;
const host = process.env.HOST || "0.0.0.0";

// Add health endpoint
app.get("/health", (_, res) => res.json({ ok: true, port, host }));

// Start server on Railway's PORT
app.listen(port, host, () => {
  console.log(`vroom-express listening on ${host}:${port}`);
  console.log(`Health check: http://${host}:${port}/health`);
});
