import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:fodome/color.dart';
import 'package:url_launcher/url_launcher.dart';

class Donation extends StatefulWidget {
  @override
  _DonationState createState() => _DonationState();
}

_linkToOpenInWebView(url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      // forceSafariVC: true,
      forceWebView: true,
      enableJavaScript: true,
    );
  } else {
    throw 'Could not launch $url';
  }
}

class _DonationState extends State<Donation> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.purple[50],
        appBar: AppBar(
          // leading: Icon(Icons.menu),
          title: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              "Donate",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 40.0,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.search),
            ),
            Icon(Icons.more_vert),
          ],
          backgroundColor: Colors.purple,
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            buildImageInteractionCard1(),
            buildImageInteractionCard2(),
            buildImageInteractionCard3(),
            buildImageInteractionCard4(),
          ],
        ),
      );

  Widget buildImageInteractionCard1() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Ink.image(
                  image: NetworkImage(
                    'https://cdn.givind.org/static/images/sharing-banner.jpg',
                  ),
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: Text(
                    'Give India Organization',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: Text(
                      'Donate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  onPressed: () => _linkToOpenInWebView(
                      "https://www.giveindia.org/missions/mission-no-child-hungry"),
                ),
              ],
            )
          ],
        ),
      );
  Widget buildImageInteractionCard2() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Ink.image(
                  image: NetworkImage(
                    'https://www.riseagainsthungerindia.org/wp-content/uploads/2020/03/RAHlogo_india-01-scaled-e1593010950565.jpg',
                  ),
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: Text(
                    'RAHI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: Text(
                      'Donate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  onPressed: () => _linkToOpenInWebView(
                      'https://www.riseagainsthunger.org/?form=meettheneed2021'),
                ),
              ],
            )
          ],
        ),
      );
  Widget buildImageInteractionCard3() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Ink.image(
                  image: NetworkImage(
                    'https://pbs.twimg.com/profile_images/1074995644383678464/aBdy_9zC_400x400.jpg',
                  ),
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: Text(
                    'Akshaya Patre',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: Text(
                      'Donate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  onPressed: () => _linkToOpenInWebView(
                      'https://www.akshayapatra.org/onlinedonations'),
                ),
              ],
            )
          ],
        ),
      );
  Widget buildImageInteractionCard4() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Ink.image(
                  image: NetworkImage(
                    'https://www.welthungerhilfe.org/typo3conf/ext/ig_project/Resources/Public/Icons/whh-logo.gif',
                  ),
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: Text(
                    'Welt Hunger Life',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: Text(
                      'Donate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  onPressed: () => _linkToOpenInWebView(
                      'https://www.welthungerhilfe.org/our-work/countries/india/'),
                ),
              ],
            )
          ],
        ),
      );
}
