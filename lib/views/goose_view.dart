import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:htn/widgets/rounded_container.dart';

class GooseView extends StatefulWidget {
  @override
  XFile? image;
  GooseViewState createState() => GooseViewState();
  GooseView({Key? key, required this.image}) : super(key: key);
}

class GooseViewState extends State<GooseView> {
  late Image imageComponent;

  @override
  void initState() {
    super.initState();
    imageComponent = Image.file(File(widget.image!.path));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        imageComponent,
        Positioned(
          bottom: 0,
          right: 0,
          child: RoundedContainer(
            child: Column(
              children: [],
            ),
          ),
        )
      ],
    );
  }
}
