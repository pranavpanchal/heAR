const express = require("express");
const getSentiment = require("./src/sentiment");
const app = express();
const port = 3000;

app.get("/", (req, res) => res.send("Hello World!"));

app.get("/sentiment", (req, res) => res.send(getSentiment()));

app.get("/translate", (req, res) => res.send("Time to translate"));

app.listen(port, () =>
  console.log(`ChatterBox app listening on port ${port}!`)
);
