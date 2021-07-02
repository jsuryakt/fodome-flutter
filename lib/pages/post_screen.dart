import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fodome/models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';

late User postUser;

class PostScreen extends StatelessWidget {
  dynamic doc;
  PostScreen({required this.doc});

  Widget title(title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 30.0,
          fontFamily: "Spotify",
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget description(description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 20.0,
          fontFamily: "Spotify",
          // fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget photo(context, photoURL) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) =>
                    FullImage(imageURL: doc['mediaUrl'])));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: CachedNetworkImage(
          imageUrl: photoURL,
          height: 275,
          width: 400,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Icon(Icons.error),
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  openMap() {
    var location = doc['location'].toString();
    MapsLauncher.launchCoordinates(doc['latitude'], doc['longitude'],
        'Opening food post location : $location');
  }

  openPhone() async {
    var phoneNumber = postUser.phone;
    var url = "tel:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget bottomButton(context, icon, String text, function) {
    return Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width * 0.5,
      child: OutlinedButton(
        onPressed: () {
          function();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(
                icon,
              ),
              // color: Colors.white,),
            ),
            Text(
              text,
              style: TextStyle(
                fontFamily: "Spotify",
                fontSize: 16.0,
                // color: Colors.white,
              ),
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          shape: BeveledRectangleBorder(),
          side: BorderSide(width: 0.2, color: Colors.deepPurple),
          // backgroundColor: Colors.deepPurple,
        ),
      ),
    );
  }

  Set<Marker> _createMarker() {
    return {
      Marker(
        markerId: MarkerId("Post Location"),
        position: LatLng(doc['latitude'], doc['longitude']),
        infoWindow: InfoWindow(title: 'Food Post Location'),
      ),
    };
  }

  Widget map() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: 200.0,
          child: GoogleMap(
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            markers: _createMarker(),
            liteModeEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(doc['latitude'], doc['longitude']),
              zoom: 15.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget dataCard(String text, data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50.0,
        width: 100.0,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text + " :  ",
                style: TextStyle(
                  fontFamily: "Spotify",
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0,
                ),
              ),
              Text(
                data.toString(),
                style: TextStyle(
                  fontFamily: "Spotify",
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getUser(doc);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Text("Post Details"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              photo(context, doc['mediaUrl']),
              title(doc['title']),
              description(doc['description']),
              dataCard("Quantity", doc['quantity']),
              dataCard("Shelf Life", doc['shelfLife']),
              map(),
            ],
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            bottomButton(context, Icons.moving_outlined, "Open Map", openMap),
            bottomButton(context, Icons.phone, "Call Donor", openPhone),
          ],
        ),
      ),
    );
  }
}

Future<void> getUser(doc) async {
  DocumentSnapshot userDoc = await usersRef.doc(doc['ownerId']).get();
  postUser = User.fromDocument(userDoc);
}

class FullImage extends StatelessWidget {
  String imageURL;
  FullImage({required this.imageURL});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: Center(
          child: Hero(
            tag: 'imageHero',
            child: CachedNetworkImage(
              imageUrl: imageURL,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
