import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:fodome/pages/activity_feed.dart';
import 'package:fodome/pages/donation.dart';
import 'package:fodome/pages/timeline.dart';
import 'package:fodome/pages/upload.dart';
import 'package:fodome/pages/profile.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  String? name = "";
  PageController? pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      name = account.displayName;
      print('User signed in: $account');
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  // logout() {
  //   googleSignIn.signOut();
  // }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController?.jumpToPage(
      pageIndex,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(name),
          // ActivityFeed(),
          Upload(),
          Donation(),
          Profile(googleSignIn),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Colors.purple,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.volunteer_activism_rounded,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
            ),
          ]),
    );
  }

  // Widget buildAuthScreen() {
  //   return MaterialApp(
  //     home: SafeArea(
  //       child: Container(
  //         color: Colors.white,
  //         child: Column(
  //           children: [
  //             Text(
  //               "Welcome to Fodome",
  //               style: TextStyle(
  //                 decoration: TextDecoration.none,
  //                 color: Colors.black,
  //                 fontFamily: 'Signatra',
  //                 fontSize: 70.0,
  //               ),
  //             ),
  //             Text(
  //               "Hello $name",
  //               style: TextStyle(
  //                 decoration: TextDecoration.none,
  //                 color: Colors.red,
  //                 fontFamily: 'Signatra',
  //                 fontSize: 50.0,
  //               ),
  //             ),
  //             VerticalDivider(
  //               width: 100.0,
  //             ),
  //             TextButton(
  //               child: Text(
  //                 "Logout",
  //                 style: TextStyle(
  //                   fontSize: 30.0,
  //                 ),
  //               ),
  //               onPressed: logout,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Scaffold buildNonAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.teal, Colors.purple],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Fodome",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildNonAuthScreen();
  }
}
