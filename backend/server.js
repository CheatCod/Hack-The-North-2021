const express = require("express");
const app = express();
const port = 3000;
const tf = require("@tensorflow/tfjs-node");
const fileUpload = require('express-fileupload');
const cors = require('cors');
const bodyParser = require('body-parser');
let model;
let is_new_od_model;

app.use(fileUpload({
  createParentPath: true
}));

//add other middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.get("/", (req, res) => {
  res.send("Hello World!");
});

const loadModel = async () => {
  console.log("Loading Model")
  model = await tf.loadGraphModel('http://127.0.0.1:8080/static/model/model.json');
  is_new_od_model = model.inputs.length == 3;
  console.log("model loaded");
};

const loadImage = async (picture) => {
  
  const input_size = model.inputs[0].shape[1];
  console.log(input_size);

  let image = tf.browser.fromPixels(picture, 3);
  // image = tf.image.resizeBilinear(image.expandDims().toFloat(), [input_size, input_size]);
  // if (is_new_od_model) {
  //   console.log("ODM V2 Detected");
  //   image = is_new_od_model ? image : image.reverse(-1);
  // }
  // return image;
}

const runPrediction = async (inputs) => {
  const ANCHORS = [0.573, 0.677, 1.87, 2.06, 3.34, 5.47, 7.88, 3.53, 9.77, 9.17];
  const NEW_OD_OUTPUT_TENSORS = ['detected_boxes', 'detected_scores', 'detected_classes'];
  const outputs = await model.executeAsync(inputs, is_new_od_model ? NEW_OD_OUTPUT_TENSORS : null);
  const arrays = !Array.isArray(outputs) ? outputs.array() : Promise.all(outputs.map(t => t.array()));
	let predictions = await arrays;

  if (predictions.length != 3) {
		console.log( "Post processing..." );
    const num_anchor = ANCHORS.length / 2;
		const channels = predictions[0][0][0].length;
		const height = predictions[0].length;
		const width = predictions[0][0].length;

		const num_class = channels / num_anchor - 5;

		let boxes = [];
		let scores = [];
		let classes = [];

		for (var grid_y = 0; grid_y < height; grid_y++) {
			for (var grid_x = 0; grid_x < width; grid_x++) {
				let offset = 0;

				for (var i = 0; i < num_anchor; i++) {
					let x = (_logistic(predictions[0][grid_y][grid_x][offset++]) + grid_x) / width;
					let y = (_logistic(predictions[0][grid_y][grid_x][offset++]) + grid_y) / height;
					let w = Math.exp(predictions[0][grid_y][grid_x][offset++]) * ANCHORS[i * 2] / width;
					let h = Math.exp(predictions[0][grid_y][grid_x][offset++]) * ANCHORS[i * 2 + 1] / height;

					let objectness = tf.scalar(_logistic(predictions[0][grid_y][grid_x][offset++]));
					let class_probabilities = tf.tensor1d(predictions[0][grid_y][grid_x].slice(offset, offset + num_class)).softmax();
					offset += num_class;

					class_probabilities = class_probabilities.mul(objectness);
					let max_index = class_probabilities.argMax();
					boxes.push([x - w / 2, y - h / 2, x + w / 2, y + h / 2]);
					scores.push(class_probabilities.max().dataSync()[0]);
					classes.push(max_index.dataSync()[0]);
				}
			}
		}
    boxes = tf.tensor2d(boxes);
		scores = tf.tensor1d(scores);
		classes = tf.tensor1d(classes);

		const selected_indices = await tf.image.nonMaxSuppressionAsync(boxes, scores, 10);
		predictions = [await boxes.gather(selected_indices).array(), await scores.gather(selected_indices).array(), await classes.gather(selected_indices).array()];
  }
  return predictions;
}

app.post("/submit-image", async (req, res) => {
  try  {
    if(!req.files) {
        res.send({
            status: false,
            message: 'No file uploaded'
        });
    } else {
        //return response
        console.log(req.files.image);
        res.send({
            status: true,
            message: 'Files are uploaded',
            filename: req.files.image.name
        });
    }
  } catch (err) {
    console.log(err);
    res.status(500).send(err);
  }

  await loadModel();
  await loadImage(req.files.image.data);

});


app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
