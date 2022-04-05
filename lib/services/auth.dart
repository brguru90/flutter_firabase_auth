import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_auth/sharedComponents/toastMessages/toastMessage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

late FirebaseAuth auth;

void initFirebaseSetup() async {
  auth = FirebaseAuth.instance;
}

void checkLoginState() {
  auth.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
      ToastMessage.error("signed out");
    } else {
      print('User is signed in!');
      ToastMessage.success("signed in");
    }
  });
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  print("credential");
  print(credential);

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

void FacebookLogin() {}
