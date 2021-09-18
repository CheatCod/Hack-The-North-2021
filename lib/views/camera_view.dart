import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../main.dart' as main;

List<CameraDescription> cameras = [];

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? controller;

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
    return MaterialApp(home: CameraPreview(controller!));
  }
}
