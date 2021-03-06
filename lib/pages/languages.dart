import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen>
    with AutomaticKeepAliveClientMixin<LanguagesScreen> {
  int languageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: Text('Languages')),
      body: SettingsList(
        backgroundColor: Colors.grey.shade100,
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
              title: "English",
              trailing: trailingWidget(0),
              onPressed: (BuildContext context) {
                changeLanguage(0);
              },
            ),
            SettingsTile(
              title: "kannada",
              trailing: trailingWidget(1),
              onPressed: (BuildContext context) {
                changeLanguage(1);
              },
            ),
            SettingsTile(
              title: "Hindi",
              trailing: trailingWidget(2),
              onPressed: (BuildContext context) {
                changeLanguage(2);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget trailingWidget(int index) {
    return (languageIndex == index)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }

  void changeLanguage(int index) {
    setState(() {
      languageIndex = index;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
