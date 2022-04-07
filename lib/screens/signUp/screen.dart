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

enum OtpStatus { none, sent, invalidOTP, invalidMobileNumber, timeout }

class _signUpScreenState extends State<signUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController mobileNumberController =
      new TextEditingController(text: "");
  final TextEditingController otpController =
      new TextEditingController(text: "");

  User? userDetail;
  OtpStatus otpStatus = OtpStatus.invalidOTP;

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

  String verificationId = "";

  Future signWithMobile(credential) async {
    try {
      var ft = await auth.signInWithCredential(credential);
      verificationId = "";
      setState(() {
        otpStatus = OtpStatus.none;
      });
      _formKey.currentState!.validate();
      otpController.text = "";
      ToastMessage.error("Mobile number verified successfully");
      return ft;
    } catch (e) {
      print(e);
      setState(() {
        otpStatus = OtpStatus.invalidOTP;
      });
      _formKey.currentState!.validate();
      ToastMessage.error("Please enter correct OTP");
    }
  }

  void verifyMobileNumber() {
    MobileAuth.verify(
        phoneNumber: mobileNumberController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // ANDROID ONLY! (automatically get the OTP)
          await signWithMobile(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          ToastMessage.error(e.toString());
          if (e.code == 'invalid-phone-number') {
            otpStatus = OtpStatus.invalidMobileNumber;
            _formKey.currentState!.validate();
            return;
          }
          print(e);
          setState(() {
            otpStatus = OtpStatus.invalidOTP;
          });
          _formKey.currentState!.validate();
        },
        codeAutoRetrievalTimeout: () {
          setState(() {
            otpStatus = OtpStatus.timeout;
          });
          _formKey.currentState!.validate();
          ToastMessage.error("Time out for auto retrieval of OTP");
        },
        codeSent: (String _verificationId, int? resendToken) {
          verificationId = _verificationId;
          setState(() {
            otpStatus = OtpStatus.sent;
          });
          _formKey.currentState!.validate();
          print("code sent");
          ToastMessage.error("code sent");
        });
  }

  void verifyOTP() async {
    if (verificationId == "") {
      ToastMessage.error("Please click 'Get OTP'");
      return;
    }
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otpController.text);

    // Sign the user in (or link) with the credential
    await signWithMobile(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SignUp"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
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
                          return 'Please enter mobile number';
                        } else if (otpStatus == OtpStatus.invalidMobileNumber) {
                          return 'Please enter valid mobile number';
                        }
                        return null;
                      },
                    ),
                    (() {
                      if (otpStatus != OtpStatus.none &&
                          otpStatus != OtpStatus.invalidMobileNumber) {
                        return Wrap(
                          children: [
                            (TextFormField(
                              controller: otpController,
                              cursorColor: Theme.of(context).cursorColor,
                              maxLength: 50,
                              decoration: InputDecoration(
                                icon: const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Icon(Icons.email),
                                ),
                                labelText: 'Enter OTP',
                                labelStyle: const TextStyle(
                                  color: Color(0xFF6200EE),
                                ),
                                helperText: 'Ex:111111',
                                suffixIcon: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Icon(
                                    otpStatus != OtpStatus.invalidOTP
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: otpStatus != OtpStatus.invalidOTP
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF6200EE)),
                                ),
                              ),
                              validator: (value) {
                                if (otpStatus == OtpStatus.invalidOTP) {
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
                      onPressed:
                          otpStatus == OtpStatus.sent ? verifyOTP : () {},
                      style: ElevatedButton.styleFrom(
                          primary: otpStatus == OtpStatus.sent
                              ? Colors.blue
                              : Colors.blue[200]),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.login),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("Verify OTP")
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
                authSignOut().then((value) {
                  userDetail = null;
                  ToastMessage.info("Signed out");
                }).catchError((e, stackTrace) =>
                    ToastMessage.warning("Error in sign out"));
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
