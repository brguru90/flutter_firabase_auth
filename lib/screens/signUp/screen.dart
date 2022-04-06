import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_auth/services/auth.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({Key? key}) : super(key: key);

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController mobileNumberController =
      new TextEditingController(text: "");
  final TextEditingController otpController =
      new TextEditingController(text: "");

  bool optSent = true;
  User? userDetail;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initState");
    bindToLoginStateChange().listen((eventValue) {
      print(eventValue);
      setState(() {
        userDetail = eventValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SignUp"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        // color: Colors.blue[50],
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: mobileNumberController,
                    cursorColor: Theme.of(context).cursorColor,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Enter mobile number',
                      labelStyle: TextStyle(
                        color: Color(0xFF6200EE),
                      ),
                      helperText: 'Ex:9482399078',
                      suffixIcon: Icon(
                        Icons.check_circle,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6200EE)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  (() {
                    if (optSent) {
                      return Wrap(
                        children: [
                          (TextFormField(
                            controller: otpController,
                            cursorColor: Theme.of(context).cursorColor,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              labelText: 'Enter OTP',
                              labelStyle: TextStyle(
                                color: Color(0xFF6200EE),
                              ),
                              helperText: 'Ex:111111',
                              suffixIcon: Icon(
                                Icons.check_circle,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF6200EE)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          )),
                          SizedBox(height: 20.0)
                        ],
                      );
                    }
                    return SizedBox(height: 0.0);
                  })(),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {},
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.login),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text("SignUp")
                        ]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () {
                      googleAuth.signIn().then((UserCredential value) {
                        print("user detail");
                        print(value.user!.email);
                        setState(() {
                          userDetail = value.user;
                        });
                      });
                    },
                    icon: Icon(
                      AntDesign.google,
                      color: Colors.blue[600],
                      size: 40.0,
                    )),
                IconButton(
                  onPressed: () {
                    fbAuth.signIn().then((UserCredential value) {
                      print("user detail");
                      print(value.user!.email);
                      setState(() {
                        userDetail = value.user;
                      });
                    });
                  },
                  icon: Icon(
                    AntDesign.facebook_square,
                    size: 40.0,
                    color: Colors.blue[600],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 40.0,
            ),
            Text(userDetail.toString())
          ],
        ),
      ),
      floatingActionButton: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
              ),
              onPressed: () {
                googleAuth.signOut();
                // setState(() {
                //   userDetail = null;
                // });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.logout,
                    size: 20.0,
                  ),
                  Text(
                    "Sign out",
                    style: TextStyle(fontSize: 12.0),
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
