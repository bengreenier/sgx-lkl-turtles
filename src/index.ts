import * as http from "http";

// tslint:disable-next-line: no-console
console.log("Hello world! Try echo server: \n" +
    "curl -d 'echo test' -X POST http://localhost:8080");

http.createServer((req, res) => {
    req.pipe(res);
}).listen(8080);
