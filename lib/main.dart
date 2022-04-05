import 'package:flutter/material.dart';
import 'package:social_auth/screens/signUp/screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'package:social_auth/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initFirebaseSetup();

  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/": (context) => signUpScreen(),
    },
  ));
}
