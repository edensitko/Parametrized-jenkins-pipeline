const http = require('http');
const port = 3000;
http.createServer((req, res) => {
  res.writeHead(200);
  res.end('Hello from Node.js Service 2');
}).listen(port, () => console.log(`Server running on port ${port}`));
