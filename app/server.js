const http = require('http');
const PORT = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  const now = new Date().toISOString();
  console.log(`${now} - ${req.method} ${req.url} - from ${req.socket.remoteAddress}`);

  if (req.url === '/health') {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('ok');
    return;
  }

  if (req.url === '/') {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello from private EC2!');
    return;
  }

  res.writeHead(404, {'Content-Type': 'text/plain'});
  res.end('Not Found');
});

server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
