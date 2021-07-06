import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter/cupertino.dart';
import 'package:fodome/models/user.dart';
import 'package:fodome/pages/home.dart';
import 'package:fodome/pages/post_screen.dart';
import 'package:fodome/widgets/progress.dart';

import 'home.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with AutomaticKeepAliveClientMixin<EditProfile> {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  late User user;
  late String userPhoto;
  bool _displayNameValid = true;
  bool _usernameValid = true;
  bool _phoneNumberValid = true;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    DocumentSnapshot doc = await usersRef.doc(currentUser!.id).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName!;
    usernameController.text = user.username!;
    phoneNumberController.text = user.phone!;
    userPhoto = user.photoUrl.toString();

    setState(() {
      isLoading = false;
    });
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      usernameController.text.trim().length < 3 ||
              usernameController.text.trim().length > 12 ||
              usernameController.text.isEmpty
          ? _usernameValid = false
          : _usernameValid = true;
      phoneNumberController.text.trim().length != 10 ||
              phoneNumberController.text.isEmpty ||
              !RegExp(r'(^[6-9][0-9]{9}$)').hasMatch(phoneNumberController.text)
          ? _phoneNumberValid = false
          : _phoneNumberValid = true;
    });

    if (_displayNameValid && _usernameValid && _phoneNumberValid) {
      setState(() {
        _status = true;
        FocusScope.of(context).requestFocus(FocusNode());
      });

      usersRef.doc(user.id).update({
        "displayName": displayNameController.text,
        "username": usernameController.text,
        "phone": phoneNumberController.text
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile updated!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? circularProgress()
            : Container(
                color: Colors.purple[50],
                child: ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: 200.0,
                          color: Colors.purple[50],
                          child: Column(
                            children: <Widget>[
                              Padding(
                                  padding:
                                      EdgeInsets.only(left: 20.0, top: 20.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(
                                              Icons.arrow_back_ios_rounded),
                                          color: Colors.grey,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          'PROFILE',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                              fontFamily: 'sans-serif',
                                              color: Colors.black),
                                        ),
                                      )
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) =>
                                              FullImage(
                                            imageURL: userPhoto,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: userPhoto,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          color: Color(0xFFF3E5F5),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Parsonal Information',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            _status
                                                ? _getEditIcon()
                                                : Container(),
                                          ],
                                        )
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Name',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Flexible(
                                          child: TextField(
                                            controller: displayNameController,
                                            decoration: const InputDecoration(
                                              hintText: "Update Name",
                                              //  errorText: "Display Name too short",
                                            ),
                                            enabled: !_status,
                                            autofocus: !_status,
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Username',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Flexible(
                                          child: TextField(
                                            controller: usernameController,
                                            decoration: const InputDecoration(
                                                hintText: "Update Username"),
                                            enabled: !_status,
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Mobile',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Flexible(
                                        child: TextField(
                                          controller: phoneNumberController,
                                          decoration: const InputDecoration(
                                              hintText: "Update Mobile Number"),
                                          enabled: !_status,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!_displayNameValid)
                                  SizedBox(
                                    height: 10,
                                    child: showError(
                                        "Display Name should be more than 3 characters"),
                                  ),
                                if (!_usernameValid)
                                  showError(
                                      "Username should be more than 3 characters and less than 12 characters"),
                                if (!_phoneNumberValid)
                                  showError(
                                      "Enter valid 10 digit Indian phone number"),
                                if (!_status) _getActionButtons(),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ));
  }

  showError(errorText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Text(
        errorText,
        style: TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: RaisedButton(
                child: Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  updateProfileData();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: RaisedButton(
                child: Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.deepPurple,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
