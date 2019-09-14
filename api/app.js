const express = require("express");
const getLanguage = require("./src/language");
const getSentiment = require("./src/sentiment");
const app = express();
const port = 3000;

app.get("/", (req, res) => res.send("Hello World!"));

app.get("/sentiment", (req, res) => {
  text = req.query.text;
  getLanguage(text, language =>
    getSentiment(
      language.documents[0].detectedLanguages[0].iso6391Name,
      text,
      sentiment => {
        res.header("Content-Type", "application/json");
        res.send(
          JSON.stringify(
            {
              results: {
                text: text,
                language:
                  language.documents[0].detectedLanguages[0].iso6391Name,
                sentiment: sentiment.documents[0].score.toString()
              }
            },
            null,
            4
          )
        );
      }
    )
  );
});

app.get("/translate", (req, res) => res.send("Time to translate"));

app.listen(port, () =>
  console.log(`ChatterBox app listening on port ${port}!`)
);
