"use strict";

module.exports = function() {
  "use strict";

  let https = require("https");

  const key_var = "DETECT_SENTIMENT_SUBSCRIPTION_KEY";
  if (!process.env[key_var]) {
    throw new Error(
      "please set/export the following environment variable: " + key_var
    );
  }
  const subscription_key = process.env[key_var];

  const endpoint_var = "DETECT_SENTIMENT_ENDPOINT";
  if (!process.env[endpoint_var]) {
    throw new Error(
      "please set/export the following environment variable: " + endpoint_var
    );
  }
  const endpoint = process.env[endpoint_var];

  let path = "/text/analytics/v2.1/sentiment";

  let response_handler = function(response) {
    let body = "";
    response.on("data", function(d) {
      body += d;
    });
    response.on("end", function() {
      let body_ = JSON.parse(body);
      let body__ = JSON.stringify(body_, null, "  ");
      console.log(body__);
    });
    response.on("error", function(e) {
      console.log("Error: " + e.message);
    });
  };

  let get_sentiments = function(documents) {
    let body = JSON.stringify(documents);

    let request_params = {
      method: "POST",
      hostname: new URL(endpoint).hostname,
      path: path,
      headers: {
        "Ocp-Apim-Subscription-Key": subscription_key
      }
    };

    let req = https.request(request_params, response_handler);
    req.write(body);
    req.end();
  };

  let documents = {
    documents: [
      {
        id: "1",
        language: "en",
        text:
          "I really enjoy the new XBox One S. It has a clean look, it has 4K/HDR resolution and it is affordable."
      },
      {
        id: "2",
        language: "es",
        text:
          "Este ha sido un dia terrible, llegué tarde al trabajo debido a un accidente automobilistico."
      }
    ]
  };

  get_sentiments(documents);
};
