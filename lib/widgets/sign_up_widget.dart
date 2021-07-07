import 'package:flutter/material.dart';
import 'package:fodome/widgets/background_painter.dart';
import 'package:fodome/widgets/google_signup_button.dart';

class SignUpWidget extends StatelessWidget {
  dynamic login;
  SignUpWidget(this.login);

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: BackgroundPainter()),
          buildSignUp(),
        ],
      );

  Widget buildSignUp() => Column(
        children: [
          Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              // width: 300,
              child: Text(
                'Welcome to\nFodome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Spotify",
                ),
              ),
            ),
          ),
          Spacer(),
          GoogleSignupButtonWidget(login),
          SizedBox(height: 12),
          Text(
            'Login to continue',
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Spotify",
            ),
          ),
          Spacer(),
        ],
      );
}
