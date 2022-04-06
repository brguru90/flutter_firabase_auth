import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_auth/sharedComponents/toastMessages/toastMessage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

late FirebaseAuth auth;

void initFirebaseSetup() async {
  auth = FirebaseAuth.instance;
}

void _signOut() {
  FirebaseAuth.instance.signOut();
}

Stream<User?> bindToLoginStateChange() {
  return auth.authStateChanges();
}

class GoogleAuth {
  late GoogleSignIn googleSignIn;
  GoogleSignInAccount? googleUser;

  GoogleAuth() {
    googleSignIn = GoogleSignIn();
  }

  Future<UserCredential> signIn() async {
    // Trigger the authentication flow
    googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signOut() {
    _signOut();
  }
}

GoogleAuth googleAuth = GoogleAuth();

class FBAuth {
  late LoginResult loginResult;
  Future<UserCredential> signIn() async {
    // Trigger the sign-in flow
    loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  void signOut() {
    _signOut();
  }
}

FBAuth fbAuth = FBAuth();
