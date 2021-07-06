import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fodome/pages/about.dart';
import 'package:fodome/pages/edit_profile.dart';
import 'package:fodome/widgets/header.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:fodome/pages/languages.dart';
import 'languages.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();

  GoogleSignIn? googleSignIn;

  Profile(GoogleSignIn googleSignIn) {
    this.googleSignIn = googleSignIn;
  }
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin<Profile> {
  logout() {
    widget.googleSignIn?.signOut();
  }

  bool value = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "User Settings",
        fontSize: 20.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: SettingsList(
          sections: [
            SettingsSection(
              title: 'Account',
              tiles: [
                SettingsTile(
                  title: 'Edit Profile',
                  leading: Icon(Icons.account_box),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Customize',
              tiles: [
                SettingsTile(
                  title: 'Language',
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) => LanguagesScreen()));
                  },
                ),
                SettingsTile.switchTile(
                  title: 'Dark Theme',
                  leading: Icon(Icons.brush),
                  switchValue: value,
                  onToggle: (bool val) {
                    setState(() {
                      value = val;
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Others',
              tiles: [
                SettingsTile(
                    title: 'View notifications',
                    leading: Icon(Icons.notifications)),
                SettingsTile(
                  title: 'Submit Feedback',
                  leading: Icon(Icons.feedback_outlined),
                ),
              ],
            ),
            SettingsSection(
              title: 'Misc',
              tiles: [
                SettingsTile(
                    title: 'Terms of Service',
                    leading: Icon(Icons.description)),
                SettingsTile(
                  title: 'About',
                  leading: Icon(Icons.perm_device_information),
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) => AboutPage()));
                  },
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: 'Logout',
                  leading: Icon(Icons.exit_to_app),
                  onTap: logout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
