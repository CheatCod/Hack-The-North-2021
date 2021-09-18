import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:htn/constants.dart';
import 'package:htn/views/goose_view.dart';
import 'package:location/location.dart';

class MyHome extends StatefulWidget {
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  Location location = Location();
  late GoogleMapController mapController;
  LatLng _center = LatLng(45.521563, -122.677433);

  _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    LocationData curLocation = await location.getLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(curLocation.latitude!.toDouble(),
            curLocation.longitude!.toDouble()),
        zoom: 17.0,
      ),
    ));
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
        zoom: 11.0,
        target: LatLng(curLocation.latitude!.toDouble(),
            curLocation.longitude!.toDouble()))));
  }

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
              zoomControlsEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
            Positioned(
              bottom: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GooseView()));
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
