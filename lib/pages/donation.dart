import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Donation extends StatefulWidget {
  @override
  _DonationState createState() => _DonationState();
}

_linkToOpenInWebView(url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceWebView: true,
      enableJavaScript: true,
    );
  } else {
    throw 'Could not launch $url';
  }
}

class _DonationState extends State<Donation> {
  Widget buildImageInteractionCard(
          {required String imageURL, required String link}) =>
      Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                TextButton(
                  onPressed: () => _linkToOpenInWebView(link),
                  child: Ink.image(
                    image: NetworkImage(
                      imageURL,
                    ),
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            donateButton(link),
          ],
        ),
      );

  ButtonBar donateButton(url) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: Text(
            'Donate',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.red,
            ),
          ),
          onPressed: () => _linkToOpenInWebView(url),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.purple[50],
        appBar: AppBar(
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
            buildImageInteractionCard(
                imageURL:
                    'https://cdn.givind.org/static/images/sharing-banner.jpg',
                link:
                    'https://www.giveindia.org/missions/mission-no-child-hungry'),
            buildImageInteractionCard(
                imageURL:
                    'https://www.riseagainsthungerindia.org/wp-content/uploads/2020/03/RAHlogo_india-01-scaled-e1593010950565.jpg',
                link:
                    'https://www.riseagainsthunger.org/?form=meettheneed2021'),
            buildImageInteractionCard(
                imageURL:
                    'https://pbs.twimg.com/profile_images/1074995644383678464/aBdy_9zC_400x400.jpg',
                link: 'https://www.akshayapatra.org/onlinedonations'),
            buildImageInteractionCard(
                imageURL:
                    'https://www.welthungerhilfe.org/typo3conf/ext/ig_project/Resources/Public/Icons/whh-logo.gif',
                link:
                    'https://www.welthungerhilfe.org/our-work/countries/india/'),
          ],
        ),
      );
}
