import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fodome/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fodome/widgets/progress.dart';
import 'package:fodome/pages/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List shortAddrs = [" ", " ", " ", " "];
  List<dynamic> users = [];
  String allPostText = "Showing all posts...";
  bool _locCheck = false;
  String text = "Enable Location";
  double currLat = 0.0, currLong = 0.0;
  double range = 20;
  bool _showCustomBar = false;
  bool _isSnackbarActive = false;
  // String userPhoto = currentUser!.photoUrl.toString();

  @override
  void initState() {
    super.initState();
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
    shortAddrs = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Location()));
    setState(() {
      this.shortAddrs = shortAddrs;
      this._locCheck = true;
      this.currLat = shortAddrs[4];
      this.currLong = shortAddrs[5];
    });
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
              label: "${range.round().toString()}",
              onChanged: (double value) {
                setState(() {
                  range = value.roundToDouble();
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
      height: 35.0,
      minWidth: 30.0,
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      onPressed: () {
        if (!_isSnackbarActive) {
          showSnack();
        }
        // showSnack();
        setState(() {
          this.range = setRange;
        });
      },
      child: Text('${setRange.toInt()}'),
      splashColor: Colors.purple[50],
    );
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
          (doc) => Container(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 9.0,
                right: 9.0,
                bottom: 10.0,
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        doc['title'],
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                    _locCheck
                        ? Text(
                            doc['distance'] + "kms away.",
                            style: TextStyle(
                                fontSize: 15.0, color: Colors.grey[600]),
                          )
                        : Text(""),
                    TextButton(
                      onPressed: () => () {},
                      child: Ink.image(
                        image: NetworkImage(doc['mediaUrl']),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        doc['description'],
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                    VerticalDivider(
                      indent: 10.0,
                    ),
                    ListTile(
                      leading: Text(
                        "Posted by " + doc['displayName'],
                        style:
                            TextStyle(fontSize: 15.0, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        (DateFormat.yMMMd()
                                .add_jm()
                                .format(doc['timestamp'].toDate()))
                            .toString(),
                        style:
                            TextStyle(fontSize: 15.0, color: Colors.grey[600]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.pin_drop,
                          color: Colors.green,
                          size: 35.0,
                        ),
                        title: Text(
                          doc['location'],
                          style: TextStyle(fontSize: 15.0),
                        ),
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
              margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _locCheck ? "Posts near $text" : allPostText,
                  style: TextStyle(
                    fontFamily: "Hind",
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
            //If location is enabled then show range options
            _locCheck
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Range (km):",
                          style: TextStyle(
                            fontFamily: "Hind",
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        rangeButton(10.0),
                        rangeButton(20.0),
                        rangeButton(50.0),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showCustomBar = !_showCustomBar;
                            });
                          },
                          child: const Text('Custom'),
                        ),
                      ],
                    ),
                  )
                : Text(""),
            //If custom is checked then show the bar.
            _showCustomBar ? selectCustomRange() : Container(),
            //If location is enabled then show no of posts under that location
            _locCheck
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Showing $noOfPosts posts under ${range.toInt()} kms",
                      style: TextStyle(
                        fontFamily: "Hind",
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                  )
                : Text(""),
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
    // print("RANGE " + range.toString());
    if (!snapshot.hasData) {
      return circularProgress();
    }

    if (_locCheck) {
      //Show loc specofic
      List<Map<String, dynamic>> lstOfPosts = [];
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
        }
        // print("Showing only these posts: ");
        // print(lstOfPosts);
        // print(doc['location']);
        // }
      });
      // var len = lstOfPosts.length;
      // print("Showing only $len posts: ");
      // print(lstOfPosts);

      return posts(lstOfPosts);
    } else {
      //Show all posts
      return posts(snapshot);
    }
  }

  @override
  Widget build(context) {
    String? userPhoto;

    if (currentUser != null) {
      userPhoto = currentUser!.photoUrl.toString();
    }

    // if (_locCheck == true) {
    //   print("CURR LAT " +
    //       currLat.toString() +
    //       "\n" +
    //       "CURR LONG " +
    //       currLong.toString());
    // }
    // if (currentUser == null) {
    //   return circularProgress();
    // }
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65.0), // here the desired height
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
              leading: IconButton(
                icon: Icon(Icons.my_location_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                            ),
                            height: 20.0,
                            width: 20.0,
                          ),
                          Text("   Loading Map...")
                        ],
                      ),
                    ),
                  );
                  gotoLocationPage();
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: userPhoto != null
                      ? ClipOval(
                          child: Image.network(userPhoto),
                        )
                      : ClipOval(
                          child: Image.asset("assets/images/blank_photo.png"),
                        ),
                ),
              ],
              // centerTitle: true,
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
    if (!_isSnackbarActive) {
      showSnack();
    }
    print("Refresh");
  }

  @override
  bool get wantKeepAlive => true;
}
