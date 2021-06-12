import 'package:flutter/material.dart';
import 'package:fodome/widgets/header.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();

  GoogleSignIn? googleSignIn;

  Profile(GoogleSignIn googleSignIn) {
    this.googleSignIn = googleSignIn;
  }
}

class _ProfileState extends State<Profile> {
  logout() {
    widget.googleSignIn?.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "User Settings",
        fontSize: 30.0,
      ),
      body: Column(
        children: [
          TextButton(
            child: Text(
              "Logout",
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
            onPressed: logout,
          ),
        ],
      ),
    );
  }
}
