import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htn/constants.dart';

import '../main.dart' as main;

List<CameraDescription> cameras = [];

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? controller;
  XFile? image;

  onImageTaken(XFile? image) {
    try {
      if (image == null) return false;
      this.image = image;
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  pickImage() async {
    try {
      ImagePicker()
          .pickImage(source: ImageSource.gallery)
          .then((image) => onImageTaken(image));
    } catch (e) {
      print(e);
    }
  }

  takeImage() async {
    try {
      controller!.takePicture().then((image) => onImageTaken(image));
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: AspectRatio(
        aspectRatio: controller!.value.aspectRatio > 1
            ? 1 / controller!.value.aspectRatio
            : controller!.value.aspectRatio,
        child: CameraPreview(controller!),
      ),
      bottomSheet: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
            color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Back Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      primary:
                          Colors.white, // <-- Button color <-- Splash color
                      elevation: 2,
                    ),
                    child: Icon(Icons.arrow_back_rounded, color: Colors.black),
                  ),
                ),
                //Take Picture Button
                Expanded(
                  flex: 2,
                  //Button to take a picture with the camera
                  child: ElevatedButton(
                    onPressed: takeImage,
                    style: ElevatedButton.styleFrom(
                      side:
                          BorderSide(width: 4, color: Constants.PrimaryYellow),
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      primary:
                          Colors.white, // <-- Button color <-- Splash color
                      elevation: 5,
                    ),
                    child: Positioned(
                      child: Image(
                        image: AssetImage('Assets/goose.png'),
                        height: 50,
                      ),
                    ),
                  ),
                ),
                //Gallery Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: pickImage,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      primary:
                          Colors.white, // <-- Button color <-- Splash color
                      elevation: 2,
                    ),
                    child: Icon(Icons.photo_library, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Find Goose",
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
