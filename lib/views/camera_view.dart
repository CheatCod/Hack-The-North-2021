import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:htn/views/goose_view.dart';
import 'package:htn/widgets/rounded_container.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htn/constants.dart';

import '../main.dart' as main;

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;

  onImageTaken(XFile? image) {
    try {
      if (image == null) return false;
      this.image = image;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GooseView(image: image, numGoose: 3)));
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

  void _showCameraException(CameraException e) {
    String errorText = 'Error:${e.code}\nError message : ${e.description}';
    print(errorText);
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller!.value.hasError) {
        print('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras!.length > 0) {
        _initCameraController(cameras![0]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });

    // controller = CameraController(cameras[0], ResolutionPreset.max);
    // controller!.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   setState(() {});
    // });
  }

  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    return Scaffold(
      body: AspectRatio(
        aspectRatio: controller!.value.aspectRatio > 1
            ? 1 / controller!.value.aspectRatio
            : controller!.value.aspectRatio,
        child: CameraPreview(controller!),
      ),
      bottomSheet: RoundedContainer(
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
                    child: Image(
                      image: AssetImage('Assets/goose.png'),
                      height: 50,
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
