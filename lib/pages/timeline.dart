import 'package:flutter/material.dart';
import 'package:fodome/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fodome/widgets/progress.dart';
import 'package:fodome/pages/location.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  List shortAddrs = [" ", " ", " ", " "];
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
  }

  Text address(List shortAddrs) {
    var text = "";
    int flag = 0;
    try {
      var lengthOfArr = shortAddrs.length;
      if (shortAddrs[lengthOfArr - 1] != null) {
        for (int idx = 0; idx < lengthOfArr - 1; idx++) {
          if (shortAddrs[idx].length > 2 && shortAddrs[idx + 1].length > 2) {
            text = shortAddrs[idx] + ",\n" + shortAddrs[idx + 1];
            if (idx <= 1) {
              flag = 1;
            }
            break;
          }
        }
      }
      if (flag == 0) {
        if (shortAddrs[0].length > 2 && shortAddrs[2].length > 2) {
          text = shortAddrs[0] + ",\n" + shortAddrs[2];
        } else if (shortAddrs[0].length > 2 && shortAddrs[3].length > 2) {
          text = shortAddrs[0] + ",\n" + shortAddrs[3];
        } else if (shortAddrs[1].length > 2 && shortAddrs[3].length > 2) {
          text = shortAddrs[1] + ",\n" + shortAddrs[3];
        }
      }
    } on Exception catch (_) {
      print('Length Null.. No locaction');
    }
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[200],
        fontFamily: "Hind",
        fontSize: 15.0,
      ),
    );
  }

  gotoLocationPage() async {
    shortAddrs = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Location()));
    setState(() {
      this.shortAddrs = shortAddrs;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          "Fodome",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Signatra",
            fontSize: 55.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Center(child: address(shortAddrs)),
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.purple[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: timelineRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Widget> children = snapshot.data!.docs
              .map(
                (doc) => Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          Text(
                            "Posted by " + doc['displayName'],
                            style: TextStyle(
                                fontSize: 15.0, color: Colors.grey[600]),
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
              child: ListView(
                children: children,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pullRefresh() async {
    print("Refresh");
  }

  @override
  bool get wantKeepAlive => true;
}
