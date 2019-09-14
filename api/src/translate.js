"use strict";

const request = require("request");
const uuidv4 = require("uuid/v4");

module.exports = function(callback) {
  var key_var = "TRANSLATE_SUBSCRIPTION_KEY";
  if (!process.env[key_var]) {
    throw new Error(
      "Please set/export the following environment variable: " + key_var
    );
  }
  var subscriptionKey = process.env[key_var];
  var endpoint_var = "TRANSLATE_ENDPOINT";
  if (!process.env[endpoint_var]) {
    throw new Error(
      "Please set/export the following environment variable: " + endpoint_var
    );
  }
  var endpoint = process.env[endpoint_var];

  let options = {
    method: "POST",
    baseUrl: endpoint,
    url: "translate",
    qs: {
      "api-version": "3.0",
      to: ["de", "it"]
    },
    headers: {
      "Ocp-Apim-Subscription-Key": subscriptionKey,
      "Content-type": "application/json",
      "X-ClientTraceId": uuidv4().toString()
    },
    body: [
      {
        text: "Hello World!"
      }
    ],
    json: true
  };

  request(options, function(err, res, body) {
    callback(body);
    console.log(body);
    console.log(JSON.stringify(body, null, 4));
  });
};
