import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GooseView extends StatelessWidget {
  File? image;

  GooseView({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.file(image!),
        Positioned(
            bottom: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Column(),
                ),
              ],
            ))
      ],
    );
  }
}
