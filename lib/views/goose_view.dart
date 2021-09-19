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
  bool isLoaded = false;
  late double _imageWidth;
  late double _imageHeight;
  @override
  void initState() {
    super.initState();

    FileImage(File(widget.image!.path))
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
          });
        })));

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
      if (_recognitions!.isEmpty) {
        log("no goose detected");
        return;
      }
      log("wtf" + receivedJson);
      log("wtf" + jsonList.first.first.toString());
      setState(() {
        isLoaded = true;
        numGoose = (jsonList.first as List).length;
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
    Size screen = MediaQuery.of(context).size;
    if (isLoaded) {
      List<Widget> test = renderBoxes(
          imageComponent.height ?? 0.0, imageComponent.width ?? 0.0, screen);
      stackChildren.addAll(test);
    }

    return Scaffold(
      body: Stack(
        children: stackChildren,
      ),
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
                maxValue: 15,
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

  List<Widget> renderBoxes(double imgHeight, double imgWidth, Size screen) {
    // if (_recognitions == null) return [];
    // if (_imageWidth == null || _imageHeight == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageHeight * screen.width;
    Color blue = Colors.blue;
    log("wtfwtf" + _recognitions![0].toString());
    return _recognitions!.map((re) {
      return Container(
        child: Positioned(
            left: (re![0] as num) * factorX + 10,
            top: (re![1] as num) * factorY - 15,
            width: (re![2] as num) * factorX + 10,
            height: (re![3] as num) * factorY - 15,
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
