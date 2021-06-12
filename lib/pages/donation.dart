import 'package:flutter/material.dart';
import 'package:fodome/widgets/header.dart';

class Donation extends StatefulWidget {
  @override
  _DonationState createState() => _DonationState();
}

class _DonationState extends State<Donation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Donate",
        fontSize: 30.0,
      ),
      body: Text(
        "Donate",
        style: TextStyle(fontSize: 30.0),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
