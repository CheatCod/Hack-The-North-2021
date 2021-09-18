import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart' as main;

List<CameraDescription> cameras = [];

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? controller;
  XFile? image;

  pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return false;
      this.image = image;
      return true;
    } catch (e) {
      return false;
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
    return MaterialApp(
      home: Scaffold(
        body: AspectRatio(
          aspectRatio: controller!.value.aspectRatio > 1
              ? 1 / controller!.value.aspectRatio
              : controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            pickImage(ImageSource.gallery);
          },
          child: Icon(Icons.photo_library),
        ),
      ),
    );
  }
}
