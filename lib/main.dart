import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:htn/Constants.dart';
import 'package:location/location.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoaded = false;
  Location location = new Location();
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

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      home: SafeArea(
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
                  onPressed: () {},
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
                      color: Colors.blue,
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
      ),
    );
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
    print("updagin");
    LocationData curLocation = await location.getLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 11.0,
        target: LatLng(curLocation.latitude!.toDouble(),
            curLocation.longitude!.toDouble()))));
  }
}
