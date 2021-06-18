import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
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
  var lat = 0.0;
  var long = 0.0;
  late LatLng _center = LatLng(lat, long);

  void initState() {
    super.initState();
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print(position);
    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      lat = position.latitude;
      long = position.longitude;
    });
    Placemark placemark = placemarks[0];
    print(placemark);
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
    });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19.0,
        ),
      ),
    );
    print(completeAddress);
    print(_center);
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
                  Navigator.pop(
                      context, [sublocality, locality, district, state]);
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
                markers: _createMarker(),
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 1.0,
                ),
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
}
