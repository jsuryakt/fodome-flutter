import 'package:flutter/material.dart';
import 'package:fodome/widgets/header.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();

  static String name = "";
  Timeline(name) {
    Timeline.name = name;
  }
}

class _TimelineState extends State<Timeline> {
  String name = Timeline.name;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Fodome",
        font: "Signatra",
        fontSize: 55.0,
      ),
      body: Text(
        "Welcome $name",
        style: TextStyle(fontSize: 30.0),
      ),
    );
  }
}
