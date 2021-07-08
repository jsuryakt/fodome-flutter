import 'package:flutter/material.dart';
import 'package:fodome/pages/home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReachUs extends StatefulWidget {
  @override
  _ReachUsState createState() => _ReachUsState();
}

class _ReachUsState extends State<ReachUs> {
  bool notValid = true;
  String subject =
      "Feedback from ${currentUser!.displayName} regarding fodome app!";
  String email = "team.fodome@gmail.com";

  launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  TextEditingController t2 = TextEditingController();
  late String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Reach Us"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 13),
              child: Text(
                "Leave us a message, and we'll get in contact with you as soon as possible. ",
                style: TextStyle(
                  fontSize: 17.5,
                  height: 1.3,
                  fontFamily: 'Spotify',
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (val) {
                  if (val.trim().length > 0) {
                    message = val;
                    notValid = false;
                  } else
                    notValid = true;
                },
                textAlign: TextAlign.start,
                controller: t2,
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade200,
                  errorText: notValid ? "Enter a valid message" : "",
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                  hintText: 'Your message / feedback / bug spot',
                  hintStyle: TextStyle(
                    color: Colors.blueGrey,
                    fontFamily: 'Spotify',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(17),
                    ),
                    borderSide: BorderSide(color: Color(0xffbdbdbd)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(17),
                    ),
                    borderSide: BorderSide(color: Color(0xffbdbdbd)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(17),
                    ),
                    borderSide: BorderSide(color: Color(0xffbdbdbd)),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.deepPurple.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                onTap: () {
                  if (!notValid) {
                    launchUrl("mailto:$email?subject=$subject&body=$message");
                    setState(() {
                      t2.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Thank you for your feedback!')));
                  }
                },
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Icon(
                        Icons.send,
                        color: Colors.white,
                      )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                      ),
                      Center(
                          child: Text(
                        "Send",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Spotify'),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05,
                  left: 21,
                  right: 21,
                  bottom: MediaQuery.of(context).size.height * 0.034),
              child: Text(
                "Alternatively, you can also report bugs and errors on following platforms",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Spotify',
                  color: Colors.blueGrey[600],
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () =>
                      launchUrl("https://github.com/jsuryakt/fodome-flutter"),
                  child: Icon(
                    FontAwesomeIcons.github,
                    color: Colors.grey[900],
                    size: 35,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.06,
                ),
                GestureDetector(
                  onTap: () => launchUrl("https://play.google.com/store/apps/"),
                  child: Icon(FontAwesomeIcons.googlePlay,
                      color: Color(0xfff48fb1), size: 35),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.06,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
