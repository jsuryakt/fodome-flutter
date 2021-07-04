import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fodome/pages/circles.dart';
import 'package:fodome/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fodome/pages/post_screen.dart';
import 'package:fodome/pages/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline>, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List shortAddrs = [" ", " ", " ", " "];
  List<dynamic> users = [];
  String allPostText = "Showing all posts...";
  bool _locCheck = false;
  String text = "Enable Location";
  double currLat = 0.0, currLong = 0.0;
  var listLatLong;
  double range = 20;
  bool _showCustomBar = false;
  bool _isSnackbarActive = false;
  bool _isLoading = true;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = BottomSheet.createAnimationController(this);
    controller.duration = Duration(seconds: 1);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String address(List shortAddrs) {
    var text = "Enable Location";
    int flag = 0;
    try {
      var lengthOfArr = 4; //sublocality, locality, district, state
      if (shortAddrs[lengthOfArr - 1] != null) {
        for (int idx = 0; idx < lengthOfArr - 1; idx++) {
          if (shortAddrs[idx].length > 2 && shortAddrs[idx + 1].length > 2) {
            text = shortAddrs[idx] + ", " + shortAddrs[idx + 1];
            if (idx <= 1) {
              flag = 1;
            }
            break;
          }
        }
      }
      if (flag == 0) {
        if (shortAddrs[0].length > 2 && shortAddrs[2].length > 2) {
          text = shortAddrs[0] + ", " + shortAddrs[2];
        } else if (shortAddrs[0].length > 2 && shortAddrs[3].length > 2) {
          text = shortAddrs[0] + ", " + shortAddrs[3];
        } else if (shortAddrs[1].length > 2 && shortAddrs[3].length > 2) {
          text = shortAddrs[1] + ", " + shortAddrs[3];
        }
      }
    } on Exception catch (_) {
      print('Length Null.. No locaction');
    }
    setState(() {
      this.text = text;
    });
    return text;
  }

  gotoLocationPage() async {
    var returnDatafromLoc;
    returnDatafromLoc = await showModalBottomSheet(
      transitionAnimationController: controller,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) => Location(),
      isScrollControlled: true,
      isDismissible: false,
    ).whenComplete(() {
      controller = BottomSheet.createAnimationController(this);
      controller.duration = Duration(seconds: 1);
    });

    if (returnDatafromLoc != null) {
      shortAddrs = returnDatafromLoc;
    } else {
      shortAddrs = [];
    }

    if (shortAddrs.length != 0) {
      setState(() {
        this.shortAddrs = shortAddrs;
        this._locCheck = true;
        this.currLat = shortAddrs[4];
        this.currLong = shortAddrs[5];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please Enable Location!"),
        ),
      );
    }
  }

  //To select a custom range using slider
  Widget selectCustomRange() {
    double min = 1, max = 1000;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${min.toInt()}",
            style: TextStyle(
              fontFamily: "Hind",
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          Expanded(
            child: Slider(
              min: min,
              max: max,
              value: this.range,
              // label: "${range.round().toString()}",
              onChanged: (double value) {
                setState(() {
                  range = value.roundToDouble();
                  _isLoading = true;
                  // To call shimmer loading setting this to true
                });
              },
            ),
          ),
          Text(
            "${max.toInt()}",
            style: TextStyle(
              fontFamily: "Hind",
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  //Sets the range to value specified and returns a button
  rangeButton(setRange) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      height: 30.0,
      minWidth: 20.0,
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      onPressed: () {
        if (!_isSnackbarActive) {
          showSnack();
        }
        // showSnack();
        setState(() {
          this.range = setRange;
          _isLoading = true;
          // To call shimmer loading setting this to true
        });
      },
      child: Text('${setRange.toInt()}'),
      splashColor: Colors.purple[50],
    );
  }

  Text distance(String distanceText) {
    return Text(
      distanceText,
      maxLines: 1,
      style: TextStyle(
        fontSize: 15.0,
        fontFamily: "Spotify",
        color: Colors.white,
      ),
    );
  }

  String getSharableText(doc) {
    String title = doc['title'].toString();
    String description = doc['description'].toString();
    String displayName = doc['displayName'].toString();
    String dateTime = DateFormat.yMMMd()
        .add_jm()
        .format(doc['timestamp'].toDate())
        .toString();
    String location = doc['location'].toString();
    String shareText =
        "Check out this food posted by $displayName\n\n\"$title\"\n\nDescription: $description\n\nPosted On: $dateTime\n\nLocation: $location \n\nCheck out more details at fodome.app";
    return shareText;
  }

  // creates shimmer container of specified height and width
  Widget loadingShimmer({required double height, required double width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Shimmer.fromColors(
        period: Duration(milliseconds: 700),
        child: Container(
          height: height,
          width: width,
          color: Color(0xFFC2C2C2),
        ),
        baseColor: Color(0xFFEFEFEF),
        highlightColor: Color(0xFFD4D4D4),
        direction: ShimmerDirection.ltr,
      ),
    );
  }

  // To call loading for seconds mentioned after which setState of loading as false
  showLoading(int seconds) {
    Future.delayed(Duration(seconds: seconds), () {
      setState(() {
        _isLoading = false;
      });
    });
    return loadingScreenUI();
  }

  // Shows 3 cards with skeleton shimmer loading
  Widget loadingScreenUI() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(
            left: 9.0,
            right: 9.0,
            bottom: 15.0,
            top: 5.0,
          ),
          child: Card(
            elevation: 3.0,
            shadowColor: Colors.grey[300],
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                loadingShimmer(height: 175, width: 400),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10.0),
                    child: loadingShimmer(height: 20, width: 300)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: loadingShimmer(height: 20, width: 100),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0, left: 5.0),
                        child: loadingShimmer(height: 20, width: 100),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8.0, left: 10.0, bottom: 8.0),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                    child: loadingShimmer(height: 20, width: 300),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  shareOptions(doc) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    if (Platform.isAndroid) {
      var url = Uri.parse(doc['mediaUrl']);
      var response = await get(url);
      final documentDirectory = (await getExternalStorageDirectory())!.path;
      File imgFile = new File('$documentDirectory/fodome_post.png');
      imgFile.writeAsBytesSync(response.bodyBytes);
      await Share.shareFiles(
        ['$documentDirectory/fodome_post.png'],
        subject: "Sharing this Food Donation Post with you from FODOME App",
        text: getSharableText(doc),
      );
    } else {
      await Share.share(getSharableText(doc),
          subject: "Sharing this Food Donation Post with you from FODOME App",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  Widget posts(snapshot) {
    var timelinePosts;
    var noOfPosts;
    if (snapshot is List<Map<String, dynamic>>) {
      timelinePosts = snapshot;
      noOfPosts = timelinePosts.length;
    } else {
      timelinePosts = snapshot.data!.docs;
    }
    List<Widget> children = timelinePosts
        .map<Widget>(
          (doc) => InkWell(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (BuildContext context) => PostScreen(
                        doc: doc,
                      )));
            },
            child: Container(
              margin: EdgeInsets.only(
                left: 9.0,
                right: 9.0,
                bottom: 15.0,
              ),
              child: Card(
                elevation: 3.0,
                shadowColor: Colors.grey[300],
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: doc['mediaUrl'],
                            height: 175,
                            width: 400,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            placeholder: (context, url) =>
                                loadingShimmer(height: 175, width: 400),
                          ),
                        ),
                        if (!_isLoading)
                          Positioned(
                            right: 0.0,
                            bottom: 8.0,
                            child: ElevatedButton(
                              onPressed: () {
                                shareOptions(doc);
                              },
                              child: Icon(Icons.share_rounded,
                                  color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(8),
                                primary: Colors.teal, // <-- Button color
                              ),
                            ),
                          ),
                        if (_locCheck)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                                color: Colors.teal,
                                shape: BoxShape.rectangle,
                              ),
                              child: doc['distance'] == "0.0"
                                  ? distance("Post is in this location")
                                  : distance(doc['distance'] + " kms away"),
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      child: Text(
                        doc['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: "Spotify",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Text(
                                "Posted by " + doc['displayName'],
                                style: TextStyle(
                                  fontFamily: "Spotify",
                                  fontSize: 15.0,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              (DateFormat.yMMMd().format(
                                doc['timestamp'].toDate(),
                              )).toString(),
                              style: TextStyle(
                                fontFamily: "Spotify",
                                fontSize: 15.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 8.0, left: 5.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.teal,
                              size: 25.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              doc['location'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Spotify",
                                fontSize: 15.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList();
    return Container(
      child: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _locCheck ? "Posts near $text" : allPostText,
                  style: TextStyle(
                    fontFamily: "Spotify",
                    fontWeight: FontWeight.w700,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
            //If location is enabled then show range options
            if (_locCheck)
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Range (km):",
                      style: TextStyle(
                        fontFamily: "Spotify",
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                    rangeButton(10.0),
                    rangeButton(20.0),
                    rangeButton(50.0),
                    SizedBox(
                      height: 30.0,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showCustomBar = !_showCustomBar;
                          });
                        },
                        child: const Text('Custom'),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 5.0,
              ),

            //If custom is checked then show the bar.
            if (_showCustomBar) selectCustomRange(),
            //If location is enabled then show no of posts under that location
            if (_locCheck)
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Showing $noOfPosts posts under ${range.toInt()} kms",
                  style: TextStyle(
                    fontFamily: "Spotify",
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
              ),
            Expanded(
              //If there are no posts then show no post image and text
              child: children.length == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/images/no_content.svg',
                            height: 260.0),
                        Divider(
                          indent: 10.0,
                        ),
                        Center(
                          child: Text(
                            "Oops! No Posts here",
                            style: TextStyle(
                              fontFamily: "Hind",
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                      ],
                    )
                  // else show posts
                  : _isLoading
                      ? showLoading(1)
                      : ListView(
                          children: children,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeline(snapshot) {
    if (!snapshot.hasData) {
      return loadingScreenUI();
    }

    if (_locCheck) {
      // If location is enabled then show the posts under that location
      //Show loc specific
      List<Map<String, dynamic>> lstOfPosts = [];
      List listLatLng = [];
      snapshot.data!.docs.forEach((DocumentSnapshot doc) {
        Map<String, dynamic> locSpecific = new Map<String, dynamic>();
        // to get posts other than posted by the same user
        // if (user!.id != doc['ownerId']) {
        var distance = (GeolocatorPlatform.instance.distanceBetween(
              currLat,
              currLong,
              doc['latitude'],
              doc['longitude'],
            ) /
            1000); //dividing by 1000 to get kms because distanceBetween() returns in mtrs

        // String loc = doc['location'];
        // print("Distance between $text and $loc is $distance");
        if (distance < range) {
          locSpecific['ownerId'] = doc['ownerId'];
          locSpecific['displayName'] = doc['displayName'];
          locSpecific['isVerified'] = doc['isVerified'];
          locSpecific['latitude'] = doc['latitude'];
          locSpecific['longitude'] = doc['longitude'];
          locSpecific['location'] = doc['location'];
          locSpecific['mediaUrl'] = doc['mediaUrl'];
          locSpecific['postId'] = doc['postId'];
          locSpecific['quantity'] = doc['quantity'];
          locSpecific['shelfLife'] = doc['shelfLife'];
          locSpecific['timestamp'] = doc['timestamp'];
          locSpecific['title'] = doc['title'];
          locSpecific['username'] = doc['username'];
          locSpecific['description'] = doc['description'];
          locSpecific['distance'] = distance.toStringAsFixed(1);
          lstOfPosts.add(locSpecific);

          listLatLng.add([
            doc['displayName'],
            doc['title'],
            LatLng(doc['latitude'], doc['longitude'])
          ]);
        }
      });
      // setState(() {
      this.listLatLong = listLatLng;
      // });
      // Shows only posts under specific location
      return posts(lstOfPosts);
    } else {
      //Show all posts
      return posts(snapshot);
    }
  }

  Widget buildSheet(context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              width: MediaQuery.of(context).size.width * 1,
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Showing posts under ${range.round()} km radius",
              style: TextStyle(
                fontFamily: "Spotify",
                // fontWeight: FontWeight.w700,
                fontSize: 18.0,
              ),
            ),
          ),
          Container(
            height: 450.0,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: CirclesMap(currLat, currLong, range, listLatLong),
            ),
          ),
        ],
      ),
    );
  }

  mapsCircle(context) {
    return showModalBottomSheet(
      transitionAnimationController: controller,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) => buildSheet(context),
      isScrollControlled: true,
    ).whenComplete(() {
      controller = BottomSheet.createAnimationController(this);
      controller.duration = Duration(seconds: 1);
    });
  }

  @override
  Widget build(context) {
    String? userPhoto;

    if (currentUser != null) {
      userPhoto = currentUser!.photoUrl.toString();
    }

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(65.0), // here the desired height for appBar
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            margin: const EdgeInsets.only(top: 10.0),
            child: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              titleSpacing: 3.0,
              title: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  _locCheck ? address(shortAddrs) : text,
                  style: TextStyle(
                    shadows: [
                      Shadow(
                        color: Colors.grey.shade100,
                        offset: Offset(0, -6),
                      )
                    ],
                    color: Colors.transparent,
                    fontFamily: "Hind",
                    fontSize: 16.0,
                    decorationColor: Colors.grey.shade400,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                    decorationThickness: 4.0,
                  ),
                ),
              ),
              leading: InkWell(
                child: Icon(Icons.my_location_rounded),
                onTap: () {
                  gotoLocationPage();
                },
              ),
              actions: [
                if (_locCheck)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        mapsCircle(context);
                      },
                      child: ClipOval(
                        child: Icon(
                          Icons.mode_standby_rounded,
                          size: 35.0,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: userPhoto != null
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (BuildContext context) => FullImage(
                                  imageURL: userPhoto!,
                                ),
                              ),
                            );
                          },
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: userPhoto,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        )
                      : ClipOval(
                          child: Image.asset("assets/images/blank_photo.png"),
                        ),
                ),
              ],
              backgroundColor: Colors.deepPurple[500],
            ),
          ),
        ),
        backgroundColor: Colors.purple[50],
        body: StreamBuilder<QuerySnapshot>(
          stream:
              timelineRef.orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            return buildTimeline(snapshot);
          },
        ),
      ),
    );
  }

  showSnack() {
    setState(() {
      _isSnackbarActive = true;
    });
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Posts updated!")))
        .closed
        .then((SnackBarClosedReason reason) {
      // snackbar is now closed.
      setState(() {
        _isSnackbarActive = false;
      });
    });
  }

  Future<void> _pullRefresh() async {
    // TO show shimmer isLoading must be true
    setState(() {
      _isLoading = true;
    });

    if (!_isSnackbarActive) {
      showSnack();
    }
    print("Refresh");
  }

  @override
  bool get wantKeepAlive => true;
}
