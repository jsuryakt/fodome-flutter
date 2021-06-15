import 'package:flutter/material.dart';
import 'package:fodome/pages/home.dart';
import 'package:fodome/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fodome/widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Fodome",
        font: "Signatra",
        fontSize: 55.0,
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
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Location - " + doc['location'],
                              style: TextStyle(fontSize: 15.0),
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
}
