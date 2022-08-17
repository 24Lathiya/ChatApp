import 'package:chat_app/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController with ChangeNotifier {
  // object
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  GoogleSignInAccount? googleSignInAccount;
  UserDetails? userDetails;

  // fucntion for google login
  Future googleLogin() async {
    try {
      googleSignInAccount = await _googleSignIn.signIn();
      final googleAuth = await googleSignInAccount!.authentication;

      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      //
      // await FirebaseAuth.instance.signInWithCredential(credential);

      userDetails = UserDetails(
        displayName: googleSignInAccount!.displayName,
        email: googleSignInAccount!.email,
        photoURL: googleSignInAccount!.photoUrl,
      );

      // call
      notifyListeners();
      return userDetails;
    } catch (error) {
      print("=== $error");
      return false;
    }
  }

  // function for facebook login
  facebooklogin() async {
    var result = await FacebookAuth.i.login(
      permissions: ["public_profile", "email"],
    );

    // check the status of our login
    if (result.status == LoginStatus.success) {
      final requestData = await FacebookAuth.i.getUserData(
        fields: "email, name, picture",
      );

      userDetails = UserDetails(
        displayName: requestData["name"],
        email: requestData["email"],
        photoURL: requestData["picture"]["data"]["url"] ?? " ",
      );
      notifyListeners();
    }
  }

  // logout

  logout() async {
    googleSignInAccount = await _googleSignIn.signOut();
    await FacebookAuth.i.logOut();
    userDetails = null;
    notifyListeners();
  }
}
