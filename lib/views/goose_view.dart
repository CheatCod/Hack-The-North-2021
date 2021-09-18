import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GooseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('Assets/test.jpg'),
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
    // TODO: implement build
  }
}
