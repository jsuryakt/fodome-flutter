import 'dart:async';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fodome/models/notification.dart';
import 'package:fodome/models/user.dart';
import 'package:fodome/pages/connection.dart';
import 'package:fodome/pages/donation.dart';
import 'package:fodome/pages/timeline.dart';
import 'package:fodome/pages/upload.dart';
import 'package:fodome/pages/profile.dart';
import 'package:fodome/widgets/background_painter.dart';
import 'package:fodome/widgets/sign_up_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fodome/pages/create_account.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:overlay_support/overlay_support.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref();
final postsRef = FirebaseFirestore.instance.collection('posts');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
User? currentUser;

ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
late StreamSubscription _connectionChangeStream;

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  bool isAuth = false;
  PageController? pageController = PageController();
  int activeIndex = 0;
  bool isSigningIn = false;

  bool isOffline = false;
  final inactiveColor = Colors.grey;

  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Checking Internet Connection
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    // print("Inside Init");
    isOffline = !connectionStatus.hasConnection;

    registerNotification();
    checkForInitialMessage();
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
      print('Error signing in silently: $err');
    });

    // For handling notification when the app is in background
    // but not terminate
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
      });
    });
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  handleSignIn(GoogleSignInAccount? account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    setState(() {
      isSigningIn = true;
    });
    // 1) check if user exists in users collection in database (according to their id)
    GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user!.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      List getDetails = await Navigator.push(
          context, CupertinoPageRoute(builder: (context) => CreateAccount()));
      var username = "", name = "", phone = "";
      if (getDetails != []) {
        username = getDetails[0];
        name = getDetails[1];
        phone = getDetails[2];
      }
      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": name,
        "bio": "",
        "phone": phone,
      });
      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    setState(() {
      isSigningIn = false;
      activeIndex = 0;
    });
  }

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          _notificationInfo = notification;
        });

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 5),
            // autoDismiss: false,
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
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

  changePage(int pageIndex) {
    setState(() {
      activeIndex = pageIndex;
      pageController!.animateToPage(pageIndex,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  Text navName(name) {
    return Text(
      name,
      style: TextStyle(fontSize: 15),
    );
  }

  Scaffold buildAuthScreen() {
    if (isOffline) {
      return noConnection();
    }
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          Upload(),
          Donation(),
          Profile(googleSignIn),
        ],
        controller: pageController,
        onPageChanged: (page) {
          setState(() {
            activeIndex = page;
          });
        },
        // physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: activeIndex,
        showElevation: true,
        iconSize: 28,
        itemCornerRadius: 50,
        containerHeight: 60,
        onItemSelected: changePage,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            title: navName("Home"),
            icon: Icon(Icons.home_rounded),
            activeColor: Colors.deepPurple,
            inactiveColor: inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            title: navName("Post"),
            icon: Icon(Icons.add_box_rounded),
            activeColor: Colors.deepOrangeAccent,
            inactiveColor: inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            title: navName("Donate"),
            icon: Icon(Icons.volunteer_activism_rounded),
            activeColor: Colors.green,
            inactiveColor: inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            title: navName("Settings"),
            icon: Icon(Icons.account_circle_rounded),
            activeColor: Colors.blueAccent,
            inactiveColor: inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildLoading() => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: BackgroundPainter(),
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 200,
                    ),
                    child: Text(
                      'Signing in...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Spotify",
                      ),
                    ),
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ],
        ),
      );

  Widget buildNonAuthScreen() {
    if (isOffline) {
      return noConnection();
    }
    if (isSigningIn) return buildLoading();
    return Scaffold(
      body: SignUpWidget(login),
    );
  }

  Scaffold noConnection() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_signal.png', height: 600.0),
          Center(
            child: Text(
              "No Internet!",
              style: TextStyle(
                fontFamily: "Spotify",
                fontSize: 20.0,
                color: Colors.red,
              ),
            ),
          ),
          Center(
            child: Text(
              "Try again",
              style: TextStyle(
                fontFamily: "Spotify",
                fontSize: 26.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    connectionChanged(connectionStatus.hasConnection);
    if (isOffline) {
      return noConnection();
    }
    return isAuth ? buildAuthScreen() : buildNonAuthScreen();
  }
}
