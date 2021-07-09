import 'package:flutter/material.dart';
import 'package:fodome/widgets/progress.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with AutomaticKeepAliveClientMixin<AboutPage> {
  bool isLoading = true;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(isLoading);
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      height: 150,
                      width: 150,
                      child: ClipOval(
                        child: Image.asset(
                            "assets/images/custom_fodome_marker.png"),
                      ),
                    ),
                    Text(
                      "fodome",
                      style: TextStyle(
                        fontFamily: "Spotify",
                        fontSize: 16.0,
                      ),
                    )
                  ],
                ),
                dataCard("",
                    "This app lets donors to donate excess food or anything which they want to donate and allow for a wide audience reach. People can contact the donors directly or can share it to others who are in need of these essentials."),
                dataCard("Version : ", _packageInfo.version.toString()),
                dataCard("Build Number : ", _packageInfo.buildNumber),
                dataCard("App name : ", _packageInfo.appName),
                dataCard("Package name : ", _packageInfo.packageName),
                dataCard("Contact : ", "team.fodome@gmail.com"),
              ],
            ),
    );
  }

  Widget dataCard(text, data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        // height: 50.0,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontFamily: "Spotify",
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0,
                ),
              ),
              Expanded(
                child: Text(
                  data,
                  // overflow: TextOverflow.,
                  style: TextStyle(
                    fontFamily: "Spotify",
                    fontSize: 16.0,
                  ),
                ),
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
