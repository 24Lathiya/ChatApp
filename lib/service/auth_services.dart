import 'package:chat_app/helper/user_preferences.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // register

  Future registerWithEmailAndPassword(
      String name, String email, String profile, String password) async {
    // print("===function call $name $email $password");

    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        await DatabaseServices(uid: user.uid).setUserData(name, email, profile);
        UserPreferences.preferences!.setBool("is_login", true);
        UserPreferences.preferences!.setString("user_name", name);
        UserPreferences.preferences!.setString("user_email", email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //login
  Future loginWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        QuerySnapshot snapshot =
            await DatabaseServices(uid: user.uid).getUserData(email);
        UserPreferences.preferences!.setBool("is_login", true);
        UserPreferences.preferences!
            .setString("user_name", snapshot.docs[0]["user_name"]);
        UserPreferences.preferences!.setString("user_email", email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //logout
  Future logoutUser() async {
    try {
      UserPreferences.preferences!.setBool("is_login", false);
      UserPreferences.preferences!.setString("user_name", "");
      UserPreferences.preferences!.setString("user_email", "");
      await FirebaseAuth.instance.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
