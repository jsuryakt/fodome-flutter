import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fodome/pages/about.dart';
import 'package:fodome/pages/termsandprivacy.dart';
import 'package:fodome/pages/edit_profile.dart';
import 'package:fodome/pages/feedback.dart';
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

  bool value = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: SettingsList(
            backgroundColor: Colors.grey.shade100,
            sections: [
              // SettingsSection(
              //   title: 'Settings',
              //   titleTextStyle: TextStyle(
              //     fontFamily: "Spotify",
              //     fontSize: 50,
              //     fontWeight: FontWeight.w700,
              //   ),
              //   tiles: [],
              // ),
              SettingsSection(
                titlePadding: EdgeInsets.only(top: 10, left: 15),
                title: 'Account',
                tiles: [
                  SettingsTile(
                    title: 'Edit Profile',
                    leading: Icon(Icons.account_box),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => EditProfile()),
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
                          builder: (BuildContext context) =>
                              LanguagesScreen()));
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
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (BuildContext context) => ReachUs()));
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Misc',
                tiles: [
                  SettingsTile(
                    title: 'Terms & Privacy Policy',
                    leading: Icon(Icons.description),
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (BuildContext context) => TermsPage()));
                    },
                  ),
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
