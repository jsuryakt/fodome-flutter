import 'package:flutter/material.dart';
import 'package:fodome/pages/connection.dart';
import 'package:fodome/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Fodome',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          primaryColor: Colors.white,
          brightness: Brightness.light,
          accentColor: Colors.black,
          accentIconTheme: IconThemeData(color: Colors.white),
          dividerColor: Colors.white54,
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.deepPurple,
          primaryColor: Colors.black,
          brightness: Brightness.dark,
          accentColor: Colors.white,
          accentIconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.black12,
          scaffoldBackgroundColor: Color(0xFF131313),
        ),
        themeMode: ThemeMode.light,
        home: Home(),
      ),
    );
  }
}
