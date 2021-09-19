import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:htn/widgets/rounded_container.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path/path.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GooseView extends StatefulWidget {
  @override
  XFile? image;
  int numGoose;
  GooseViewState createState() => GooseViewState();
  GooseView({Key? key, required this.image, required this.numGoose})
      : super(key: key);
}

class GooseViewState extends State<GooseView> {
  late Image imageComponent;
  int numGoose = 0;
  List<dynamic>? _recognitions;
  late double _imageWidth, _imageHeight;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();

    imageComponent = Image.file(File(widget.image!.path));
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      upload(widget.image!.path);
    });
  }

  upload(String imageFile) async {
    // open a bytestream
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://34.67.55.46/get-goose'));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      //log("wtf" + await response.stream.bytesToString());
      String receivedJson = await response.stream.bytesToString();
      List<dynamic> jsonList = json.decode(receivedJson);
      _recognitions = jsonList.first;
      log("wtf" + receivedJson);
      log("wtf" + jsonList.first.first.toString());
      setState(() {
        isLoaded = true;
      });
    } else {
      log(response.reasonPhrase.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    stackChildren.add(
      Positioned(
        child: imageComponent,
      ),
    );
    stackChildren.add(
      Positioned(
        bottom: 0,
        child: RoundedContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (numGoose <= 1) ? Text("There is") : Text("There are"),
              Padding(
                padding: EdgeInsets.all(15),
                child: NumberPicker(
                  value: numGoose,
                  minValue: 0,
                  maxValue: 5,
                  onChanged: (value) => setState(() => numGoose = value),
                  itemCount: 1,
                  itemHeight: 80,
                  selectedTextStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 70),
                  textStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 70),
                  haptics: true,
                ),
              ),
              (numGoose == 0) ? Text("Geese") : Text("Goose"),
            ],
          ),
        ),
      ),
    );

    Size size = MediaQuery.of(context).size;
    if (isLoaded) {
      stackChildren.addAll(renderBoxes(size));
    }
    return Scaffold(
      body: Stack(
        children: stackChildren,
      ),
    );

    return Scaffold(
      body: imageComponent,
      bottomSheet: RoundedContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (numGoose <= 1) ? Text("There is") : Text("There are"),
            Padding(
              padding: EdgeInsets.all(15),
              child: NumberPicker(
                value: numGoose,
                minValue: 0,
                maxValue: 5,
                onChanged: (value) => setState(() => numGoose = value),
                itemCount: 1,
                itemHeight: 80,
                selectedTextStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 70),
                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 70),
                haptics: true,
              ),
            ),
            (numGoose == 0) ? Text("Geese") : Text("Goose"),
          ],
        ),
      ),
    );
  }

  List<Widget> renderBoxes(Size screen) {
    // if (_recognitions == null) return [];
    // if (_imageWidth == null || _imageHeight == null) return [];

    // double factorX = screen.width;
    // double factorY = _imageHeight / _imageHeight * screen.width;
    Color blue = Colors.blue;
    return _recognitions!.map((re) {
      return Container(
        child: Positioned(
            left: _recognitions!.indexOf(0) * screen.width,
            top: _recognitions!.indexOf(1) * screen.height,
            width: _recognitions!.indexOf(2) * screen.width,
            height: _recognitions!.indexOf(3) * screen.width,
            child: ((1 > 0.50))
                ? Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: blue,
                      width: 3,
                    )),
                    // child: Text(
                    //   "${re["detectsedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                    //   style: TextStyle(
                    //     background: Paint()..color = blue,
                    //     color: Colors.white,
                    //     fontSize: 15,
                    //   ),
                    // ),
                  )
                : Container()),
      );
    }).toList();
  }
}
