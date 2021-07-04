import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fodome/widgets/progress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location>
    with AutomaticKeepAliveClientMixin<Location> {
  bool _clickedOnLocation = false;
  late GoogleMapController mapController;
  String? address = "";
  String? locality = "";
  String? state = "";
  String? sublocality = "";
  String? district = "";
  var lat = 20.593684;
  var long = 78.96288;
  bool _isLoading = true;

  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
    getUserLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude);

    if (mounted) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17.0,
          ),
        ),
      );
    }

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

    if (mounted) {
      setState(() {
        lat = position.latitude;
        long = position.longitude;
        address = completeAddress;
        state = placemark.administrativeArea;
        district = placemark.subAdministrativeArea;
        locality = placemark.locality;
        sublocality = placemark.subLocality;
        _clickedOnLocation = true;
      });
    }
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
        infoWindow: InfoWindow(title: 'Current Location'),
      )
    ].toSet();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Future<bool> ret;
        if (_clickedOnLocation) {
          Navigator.pop(
              context, [sublocality, locality, district, state, lat, long]);
        } else {
          Navigator.pop(context, []);
        }
        ret = true as Future<bool>;
        return ret;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                if (_clickedOnLocation) {
                  Navigator.pop(context,
                      [sublocality, locality, district, state, lat, long]);
                } else {
                  Navigator.pop(context, []);
                }
              },
              child: Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                width: MediaQuery.of(context).size.width * 1,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey, size: 40),
              ),
            ),
            Container(
              height: 400.0,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _isLoading
                    ? circularProgress()
                    : GoogleMap(
                        mapType: MapType.normal,
                        markers: _createMarker(),
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(lat, long),
                          zoom: 3.5,
                        ),
                        scrollGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        trafficEnabled: false,
                        indoorViewEnabled: false,
                        compassEnabled: false,
                        rotateGesturesEnabled: false,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        liteModeEnabled: false,
                        myLocationEnabled: false,
                        buildingsEnabled: false,
                      ),
              ),
            ),
            if (!_clickedOnLocation)
              Container(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                      ),
                      height: 20.0,
                      width: 20.0,
                    ),
                    Text(
                      "   Detecting Location...",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        fontFamily: 'Spotify',
                        // color: Colors.grey[800]
                      ),
                    )
                  ],
                ),
              ),
            if (_clickedOnLocation)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Current Location : \n" + address!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    fontFamily: 'Spotify',
                  ),
                ),
              ),
            if (_clickedOnLocation)
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                height: 40.0,
                width: MediaQuery.of(context).size.width * 0.85,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context,
                        [sublocality, locality, district, state, lat, long]);
                  },
                  child: Text(
                    "Confirm Location",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Spotify',
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
