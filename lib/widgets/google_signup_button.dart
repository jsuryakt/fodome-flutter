import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleSignupButtonWidget extends StatelessWidget {
  dynamic login;
  GoogleSignupButtonWidget(this.login);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(5),
        child: OutlineButton.icon(
          label: Text(
            'Sign In with Google',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              fontFamily: "Spotify",
            ),
          ),
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          highlightedBorderColor: Colors.black,
          borderSide: BorderSide(color: Colors.black),
          textColor: Colors.black,
          icon: FaIcon(FontAwesomeIcons.google, color: Colors.deepPurple),
          onPressed: () {
            login();
          },
        ),
      );
}
