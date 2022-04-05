import 'package:flutter/material.dart';
import 'package:social_auth/screens/login/screen.dart';
import 'package:social_auth/screens/signUp/screen.dart';

void main() async {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/": (context) => signUpScreen(),
    },
  ));
}
