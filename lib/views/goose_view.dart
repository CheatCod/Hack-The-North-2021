import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GooseView extends StatelessWidget {
  File? image;

  GooseView({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.file(image!),
        Positioned(
            child: Column(
          children: [
            Container(
              color: Colors.red,
            )
          ],
        ))
      ],
    );
  }
}
