import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_auth/services/auth.dart';
import 'package:social_auth/sharedComponents/toastMessages/toastMessage.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({Key? key}) : super(key: key);

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

enum OtpStatus { none, sent, invalid, timeout }

class _signUpScreenState extends State<signUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController mobileNumberController =
      new TextEditingController(text: "");
  final TextEditingController otpController =
      new TextEditingController(text: "");

  User? userDetail;
  OtpStatus otpStatus = OtpStatus.invalid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initState");
    bindToLoginStateChange().listen((eventValue) {
      print(eventValue);
      if (eventValue == null) {
        ToastMessage.error("Logged out");
      } else {
        ToastMessage.success("Logged in");
      }
      setState(() {
        userDetail = eventValue;
      });
    });
  }

  void verifyMobileNumber() {
    MobileAuth.verify(
        phoneNumber: mobileNumberController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          setState(() {
            otpStatus = OtpStatus.none;
            userDetail = UserCopy()..phoneNumber = mobileNumberController.text;
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          ToastMessage.error(e.toString());
          print(e.toString());
          // if(e.code == 'invalid-phone-number'){
          //   return;
          // }
          setState(() {
            otpStatus = OtpStatus.invalid;
          });
          _formKey.currentState!.validate();
        },
        codeAutoRetrievalTimeout: () {
          setState(() {
            otpStatus = OtpStatus.timeout;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            otpStatus = OtpStatus.sent;
          });
          print("code sent");
          ToastMessage.error("code sent");
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
                    maxLength: 13,
                    keyboardType: TextInputType.text,
                    // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      icon: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Icon(Icons.email),
                      ),
                      labelText: 'Enter mobile number',
                      labelStyle: const TextStyle(
                        color: Color(0xFF6200EE),
                      ),
                      helperText: 'Ex:+919482399078',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                        child: TextButton(
                          onPressed: verifyMobileNumber,
                          style: TextButton.styleFrom(
                            // fixedSize: Size.fromHeight(1),
                            minimumSize: Size(0, 0),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 10.0,
                              ),
                              Text("Get OTP"),
                              SizedBox(
                                width: 10.0,
                              ),
                              Icon(Icons.send)
                            ],
                          ),
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
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
                    if (otpStatus == OtpStatus.timeout ||
                        otpStatus == OtpStatus.invalid) {
                      return Wrap(
                        children: [
                          (TextFormField(
                            controller: otpController,
                            cursorColor: Theme.of(context).cursorColor,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              icon: Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child: Icon(Icons.email),
                              ),
                              labelText: 'Enter OTP',
                              labelStyle: TextStyle(
                                color: Color(0xFF6200EE),
                              ),
                              helperText: 'Ex:111111',
                              suffixIcon: Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child: Icon(
                                  Icons.check_circle,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF6200EE)),
                              ),
                            ),
                            validator: (value) {
                              if (otpStatus == OtpStatus.invalid) {
                                return 'Please valid otp';
                              }
                              return null;
                            },
                          )),
                          SizedBox(height: 20.0)
                        ],
                      );
                    }
                    return SizedBox(
                      height: 10.0,
                    );
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
