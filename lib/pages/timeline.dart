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
    // getUsers();
    // getUsers();
    super.initState();
  }

  // getUsers() async {
  //   final snapshot = await usersRef.get();

  //   setState(() {
  //     users = snapshot.docs;
  //   });
  // }
  // usersRef.get().then((QuerySnapshot snapshot) {
  //   snapshot.docs.forEach((DocumentSnapshot doc) {
  //     print(doc.data());
  //     print(doc.id);
  //     print(doc.exists);
  //   });
  // });

  // getUserById() async {
  //   final String id = "1u9Qpt4KXc4oFo8pzFOB";
  //   final DocumentSnapshot doc = await usersRef.doc(id).get();
  //   print(doc.data());
  //   print("OOOOOOOOOOOOOOOOOOOOOOOOOOOO" + doc.id);
  //   print(doc.exists);
  // }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Fodome",
        font: "Signatra",
        fontSize: 55.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: timelineRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Widget> children = snapshot.data!.docs
              .map(
                (doc) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        doc['title'],
                        style: TextStyle(fontSize: 25.0),
                      ),
                      TextButton(
                        onPressed: () => () {},
                        child: Ink.image(
                          image: NetworkImage(doc['mediaUrl']),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        doc['description'],
                        style: TextStyle(fontSize: 22.0),
                      ),
                      VerticalDivider(
                        indent: 10.0,
                      ),
                      Text(
                        "Posted by " + doc['displayName'],
                        style: TextStyle(fontSize: 15.0),
                      ),
                      Text(
                        "Location " + doc['location'],
                        style: TextStyle(fontSize: 15.0),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                    ],
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
