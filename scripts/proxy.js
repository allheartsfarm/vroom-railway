const http = require('http');
const https = require('https');

const TARGET_HOST = process.env.TARGET_HOST || 'allheartsfarm-valhalla.up.railway.app';
const TARGET_PORT = parseInt(process.env.TARGET_PORT || '443', 10);
const LISTEN_PORT = parseInt(process.env.PROXY_PORT || '9002', 10);

const server = http.createServer((clientReq, clientRes) => {
  const chunks = [];
  clientReq.on('data', (c) => chunks.push(c));
  clientReq.on('end', () => {
    const body = Buffer.concat(chunks);

    const options = {
      hostname: TARGET_HOST,
      port: TARGET_PORT,
      path: clientReq.url,
      method: clientReq.method,
      headers: {
        ...clientReq.headers,
        host: TARGET_HOST,
      },
    };

    const proxyReq = https.request(options, (proxyRes) => {
      // Forward status and headers
      clientRes.writeHead(proxyRes.statusCode || 502, proxyRes.headers);
      proxyRes.pipe(clientRes);
    });

    proxyReq.on('error', (err) => {
      clientRes.statusCode = 502;
      clientRes.setHeader('content-type', 'application/json');
      clientRes.end(
        JSON.stringify({ error: 'proxy_error', message: err.message })
      );
    });

    if (body.length > 0) {
      proxyReq.write(body);
    }
    proxyReq.end();
  });
});

server.listen(LISTEN_PORT, '0.0.0.0', () => {
  console.log(
    `valhalla https proxy listening on 0.0.0.0:${LISTEN_PORT} → https://${TARGET_HOST}:${TARGET_PORT}`
  );
});


