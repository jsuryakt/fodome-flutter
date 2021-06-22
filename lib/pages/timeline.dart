import 'package:flutter/material.dart';
import 'package:fodome/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fodome/widgets/progress.dart';
import 'package:fodome/pages/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
GoogleSignInAccount? user = googleSignIn.currentUser;

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  String userPhoto = user!.photoUrl.toString();
  List shortAddrs = [" ", " ", " ", " "];
  List<dynamic> users = [];
  String allPostText = "Showing all posts...";
  bool _locCheck = false;
  String text = "Enable Location";
  double currLat = 0.0, currLong = 0.0;

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

  Widget posts(snapshot) {
    var timelinePosts;
    if (snapshot is List<Map<String, dynamic>>) {
      timelinePosts = snapshot;
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
                      // trailing: Text(doc['timestamp']
                      //     .substring(0, doc['timestamp'].length - 9)),
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
              margin: EdgeInsets.all(15.0),
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
            Expanded(
              child: ListView(
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
                1000) //dividing by 1000 to get kms because distanceBetween() returns in mtrs
            .round();
        String loc = doc['location'];
        print("Distance between $text and $loc is $distance");
        if (distance < 20) {
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

          lstOfPosts.add(locSpecific);
        }
        // print("Showing only these posts: ");
        // print(lstOfPosts);
        // print(doc['location']);
        // }
      });
      var len = lstOfPosts.length;
      print("Showing only $len posts: ");
      print(lstOfPosts);

      return posts(lstOfPosts);
    } else {
      //Show all posts
      return posts(snapshot);
    }
  }

  @override
  Widget build(context) {
    if (_locCheck == true) {
      print("CURR LAT " +
          currLat.toString() +
          "\n" +
          "CURR LONG " +
          currLong.toString());
    }
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
                  child: ClipOval(
                    child: Image.network(userPhoto),
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

  Future<void> _pullRefresh() async {
    print("Refresh");
  }

  @override
  bool get wantKeepAlive => true;
}
