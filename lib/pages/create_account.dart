import 'package:flutter/material.dart';
import 'dart:async';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username = "", name = "", phone = "";
  late List<dynamic> lst = [username, name, phone];

  submit() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Welcome $name')));
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, lst);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Set up your profile",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text(
                        "Enter Profile Details:",
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: TextFormField(
                        validator: (val) {
                          if (val!.trim().length < 3 || val.isEmpty) {
                            return "Name too short";
                          } else if (val.trim().length > 12) {
                            return "Name too long";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => name = val!,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Display Name",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be at least 3 characters",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: TextFormField(
                        validator: (val) {
                          if (val!.trim().length < 3 || val.isEmpty) {
                            return "Username too short";
                          } else if (val.trim().length > 12) {
                            return "Username too long";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => username = val!,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be at least 3 characters",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: TextFormField(
                        validator: (val) {
                          String patttern = r'(^[6-9][0-9]{9}$)';
                          RegExp regExp = new RegExp(patttern);
                          if (val!.trim().length != 10 || val.isEmpty) {
                            return "Please Enter 10 digit phone number without STD code";
                          } else if (!regExp.hasMatch(val)) {
                            return "Invalid! Please Enter 10 digit Indian phone number only";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => phone = val!,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Phone Number",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must be 10 digit number",
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
