const express = require("express");
const getLanguage = require("./src/language");
const app = express();
const port = 3000;

app.get("/", (req, res) => res.send("Hello World!"));

app.get("/sentiment", (req, res) => {
  getLanguage(response =>
    res.send(response.documents[0].detectedLanguages[0].iso6391Name)
  );
});

app.get("/translate", (req, res) => res.send("Time to translate"));

app.listen(port, () =>
  console.log(`ChatterBox app listening on port ${port}!`)
);
