import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:htn/constants.dart';
import 'package:htn/views/camera_view.dart';
import 'package:htn/views/goose_view.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';

class MyHome extends StatefulWidget {
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with WidgetsBindingObserver {
  Location location = Location();
  late GoogleMapController mapController;
  // LatLng _center = LatLng(45.521563, -122.677433);

  LatLng _center = LatLng(43.468917, -80.538172);

  _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    LocationData curLocation = await location.getLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(curLocation.latitude!.toDouble(),
            curLocation.longitude!.toDouble()),
        zoom: 11.0,
      ),
    ));

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('goose1'),
          position: LatLng(43.469117, -80.538172),
          // position: LatLng(45.521563, -122.677433),
          infoWindow: InfoWindow(title: 'goose'),
          icon: myPinIcon));
    });
  }

  requestPermission() async {
    var _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    } else
      return;
  }

  goCurPosition() async {
    LocationData curLocation = await location.getLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 18.0,
        target: LatLng(curLocation.latitude!.toDouble(),
            curLocation.longitude!.toDouble()))));
  }

  late BitmapDescriptor myPinIcon;

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    myPinIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'Assets/goose4.png');
  }

  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return SafeArea(
      top: false,
      child: Scaffold(
        primary: true,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
                markers: _markers,
                zoomControlsEnabled: false,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomGesturesEnabled: true // ! get min max zoom
                ),
            Positioned(
              bottom: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CameraView()));
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(width: 4, color: Constants.PrimaryYellow),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  primary: Colors.white, // <-- Button color <-- Splash color
                  elevation: 5,
                ),
                child: Positioned(
                  child: Image(
                    image: AssetImage('Assets/goose.png'),
                    height: 50,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 23,
              right: 23,
              child: Material(
                color: Constants.transparent,
                child: Ink(
                  height: 40,
                  width: 40,
                  decoration: const ShapeDecoration(
                    color: Constants.Blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.location_pin),
                    color: Colors.white,
                    onPressed: goCurPosition,
                    iconSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
