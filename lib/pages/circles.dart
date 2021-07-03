import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fodome/widgets/progress.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CirclesMap extends StatefulWidget {
  late double currLat, currLong;
  late double radius;
  late List listLatLng;
  CirclesMap(currLat, currLong, radius, listLatLng) {
    this.currLat = currLat;
    this.currLong = currLong;
    this.radius = radius;
    this.listLatLng = listLatLng;
  }

  @override
  _CirclesMapState createState() => _CirclesMapState();
}

class _CirclesMapState extends State<CirclesMap> {
  Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();
  late GoogleMapController _googleMapController;
  late BitmapDescriptor _markerIcon;
  int _markerIdCounter = 1;
  bool isLoading = true;

  @override
  void initState() {
    // To change the marker icon:
    _setMarkerIcon().whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
    // To show circular progress when marker is loading

    super.initState();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
      String path, int width) async {
    final Uint8List imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData);
  }

  // This function is to change the marker icon
  _setMarkerIcon() async {
    _markerIcon = await getBitmapDescriptorFromAssetBytes(
        "assets/images/custom_fodome_marker.png", 100);
    // _markerIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(size: Size(24, 24)),
    //     'assets/images/custom_fodome_marker.png');
  }

  // Start the map with this marker setted up
  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;

    setState(() {
      widget.listLatLng.forEach((point) {
        _markers.add(
          Marker(
            markerId: MarkerId(_markerIdCounter.toString()),
            position: point[2], //LatLng
            infoWindow: InfoWindow(
                title:
                    'Food Post $_markerIdCounter by ${point[0].toString()}', //0 for displayName
                snippet: '${point[1].toString()}'), //1 for title
            icon: _markerIcon,
          ),
        );
        _markerIdCounter++;
      });
      _circles.add(Circle(
          circleId: CircleId("1"),
          center: LatLng(widget.currLat, widget.currLong),
          radius: widget.radius * 1000,
          fillColor: Colors.teal.withOpacity(0.1),
          strokeWidth: 3,
          strokeColor: Colors.teal.shade200));
    });

    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.currLat, widget.currLong),
          zoom: getZoomLevel(),
        ),
      ),
    );
  }

  double getZoomLevel() {
    double zoomLevel = 0.0;
    double newRadius = widget.radius + widget.radius / 2;
    double scale = newRadius / 500;
    zoomLevel = (6 - log(scale) / log(2));
    return zoomLevel;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? circularProgress()
        : Container(
            height: 450.0,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.currLat, widget.currLat),
              ),
              markers: _markers,
              // cameraTargetBounds : CameraTargetBounds.,
              onMapCreated: _onMapCreated,
              circles: _circles,
              myLocationEnabled: true,
            ),
          );
  }
}
