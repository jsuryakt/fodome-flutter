import 'package:flutter/material.dart';

AppBar header(context,
    {String titleText = "", String font = "", double fontSize = 0.0}) {
  return AppBar(
    title: Text(
      titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: font,
        fontSize: fontSize,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.purple,
  );
}
