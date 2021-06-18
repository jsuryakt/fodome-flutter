import 'package:flutter/material.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen>
    with AutomaticKeepAliveClientMixin<LanguagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Languages')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('English'),
          ),
          ListTile(
            title: Text('Kannada'),
          ),
          ListTile(
            title: Text('Hindi'),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
