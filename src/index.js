const http = require('http');

console.log("Hello world. I'm inside an enclave!")

http.createServer(function (req, res) {
    req.pipe(res)
}).listen(8080)