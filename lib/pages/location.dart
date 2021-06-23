import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location>
    with AutomaticKeepAliveClientMixin<Location> {
  var buttonTextStart = "Detect My Location";
  var buttonTextSearch = "Detecting...";
  bool _whichButtonText = false;
  bool _clickedOnLocation = false;
  late GoogleMapController mapController;
  String? address;
  String? locality;
  String? state;
  String? sublocality;
  String? district;
  var lat = 20.593684;
  var long = 78.96288;

  void initState() {
    super.initState();
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude);

    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });

    Placemark placemark = placemarks[0];
    String completeAddress = "";

    if (placemark.subThoroughfare != "") {
      completeAddress = placemark.subThoroughfare! + ", ";
    }
    if (placemark.thoroughfare != "") {
      completeAddress += placemark.thoroughfare! + ", ";
    }
    if (placemark.name != "" && placemark.name != placemark.street) {
      completeAddress += placemark.name! + ", ";
    }

    completeAddress +=
        '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';

    setState(() {
      _whichButtonText = false;
      address = completeAddress;
      _clickedOnLocation = true;
      state = placemark.administrativeArea;
      district = placemark.subAdministrativeArea;
      locality = placemark.locality;
      sublocality = placemark.subLocality;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Taking you to home..'),
          duration: const Duration(seconds: 2),
        ),
      );
      Timer(Duration(seconds: 3), () {
        Navigator.pop(
            context, [sublocality, locality, district, state, lat, long]);
      });
    });

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19.0,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: 'Current Location'))
    ].toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _clickedOnLocation
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context,
                      [sublocality, locality, district, state, lat, long]);
                },
                icon: Icon(Icons.arrow_back_ios_new_rounded),
              )
            : Text(""),
        title: Text("Get current location"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              height: 300.0,
              child: GoogleMap(
                mapType: MapType.normal,
                markers: _createMarker(),
                // liteModeEnabled: true,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, long),
                  zoom: 1.0,
                ),
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: true,
                trafficEnabled: false,
                indoorViewEnabled: true,
                compassEnabled: true,
                rotateGesturesEnabled: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                shape: StadiumBorder(),
              ),
              onPressed: () {
                setState(() {
                  _whichButtonText = true;
                  _clickedOnLocation = false;
                });
                getUserLocation();
              },
              child:
                  Text(_whichButtonText ? buttonTextSearch : buttonTextStart),
            ),
            SizedBox(height: 20),
            if (_clickedOnLocation)
              Text(
                "Current Location is \n" + address!,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    fontFamily: 'Roboto',
                    color: Colors.grey[800]),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
