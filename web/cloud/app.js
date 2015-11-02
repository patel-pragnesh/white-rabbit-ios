var app, express, parseAdaptor;

express = require("express");

app = express();

parseAdaptor = require("cloud/prerender-parse.js");

app.use(require("cloud/prerenderio.js").setAdaptor(parseAdaptor(Parse)).set("prerenderToken", "OnBuGOnWjpPCOA2oC91v"));

app.set("views", "cloud/views");

app.set("view engine", "ejs");

app.use(express.bodyParser());

app.listen();
