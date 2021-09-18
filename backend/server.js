const express = require("express");
const app = express();
const port = 3000;
// const cvstfjs = require("@microsoft/customvision-tfjs");
const tf = require("@tensorflow/tfjs-node");
const modelJson = require("./static/model/model.json");

app.get("/", (req, res) => {
  res.send("Hello World!");
});

const loadModel = async () => {
  console.log("loading model", modelJson);
  let model = await tf.loadGraphModel("./static/model/model.json");
  console.log("model loaded");
  //   return result;
};

app.get("/submit-image", (req, res) => {
  loadModel();
  res.send("Submitting image to model for processing.");
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
