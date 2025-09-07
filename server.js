import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { spawn } from 'child_process';
import { writeFileSync } from 'fs';

const app = express();
const port = process.env.PORT || 3000;

// Generate vroom config.yml
const generateVroomConfig = () => {
  const config = `# Vroom configuration
vroom:
  router: ${process.env.VROOM_ROUTER || 'valhalla'}
  geometry: true
  
routing:
  valhalla:
    servers:
      - host: ${process.env.VALHALLA_HOST || 'https://allheartsfarm-valhalla.up.railway.app'}
        port: ${process.env.VALHALLA_PORT || '443'}
        use_https: ${process.env.VALHALLA_USE_HTTPS || 'true'}
`;

  writeFileSync('/tmp/vroom-config.yml', config);
  console.log('Generated vroom config:', config);
};

// Start vroom-express in background
let vroomProcess;
const startVroom = () => {
  console.log('Starting vroom-express...');
  generateVroomConfig();
  
  // Start vroom-express on port 8080
  vroomProcess = spawn('vroom-express', ['--config', '/tmp/vroom-config.yml', '--port', '8080'], {
    stdio: 'inherit',
    env: { ...process.env, PORT: '8080' }
  });
  
  vroomProcess.on('error', (err) => {
    console.error('Failed to start vroom-express:', err);
  });
  
  vroomProcess.on('exit', (code) => {
    console.log('vroom-express exited with code:', code);
  });
};

// Health endpoint
app.get('/health', (req, res) => {
  res.json({ 
    ok: true, 
    port, 
    vroom_router: process.env.VROOM_ROUTER || 'valhalla',
    valhalla_host: process.env.VALHALLA_HOST || 'https://allheartsfarm-valhalla.up.railway.app'
  });
});

// Proxy all other requests to vroom-express
const vroomProxy = createProxyMiddleware({
  target: 'http://localhost:8080',
  changeOrigin: true,
  timeout: 30000,
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(502).json({ error: 'Vroom service unavailable', message: err.message });
  }
});

app.use('/', vroomProxy);

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down...');
  if (vroomProcess) {
    vroomProcess.kill();
  }
  process.exit(0);
});

// Start services
console.log(`Starting proxy server on port ${port}`);
console.log(`Environment: VROOM_ROUTER=${process.env.VROOM_ROUTER}, VALHALLA_HOST=${process.env.VALHALLA_HOST}`);

// Wait a moment then start vroom
setTimeout(startVroom, 2000);

app.listen(port, '0.0.0.0', () => {
  console.log(`Vroom proxy listening on 0.0.0.0:${port}`);
});
