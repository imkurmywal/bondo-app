import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Future createNewUserWithEmail(String email, String password) async {
    try {
      print("Email : $email , Pass : $password");
      final results = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return results.user;
    } catch (e) {
      return e;
    }
  }

  static Future loginWithEmail(String email, String password) async {
    try {
      final results = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return results.user;
    } catch (e) {
      return e;
    }
  }

  static Future loginWithGoogle() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      var user = (await _auth.signInWithCredential(credential)).user;
      if (user is FirebaseUser)
        return true;
      else
        return "Error Occured";
    } catch (e) {
      return e.toString();
    }
  }

  static logout() {
    _auth.signOut();
  }

  static getCurrentUser() async {
    return await _auth.currentUser();
  }
}
