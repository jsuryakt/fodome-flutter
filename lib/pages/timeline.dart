import 'package:flutter/material.dart';
import 'package:fodome/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fodome/widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();

  static String name = "";
  Timeline(name) {
    Timeline.name = name;
  }
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];
  String name = Timeline.name;

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
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data!.docs
              .map(
                (doc) => Text(
                  doc['username'],
                  style: TextStyle(fontSize: 20.0),
                ),
              )
              .toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
