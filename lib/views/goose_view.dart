import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:htn/widgets/rounded_container.dart';

class GooseView extends StatelessWidget {
  Image? image;

  GooseView({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(image: image!.image),
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
