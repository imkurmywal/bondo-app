import 'package:bondo/model/user.dart';
import 'package:bondo/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

Future register(User user, String password) async {
  final _db = Firestore.instance;
  var res = await AuthService.createNewUserWithEmail(user.email, password);
  if (res is FirebaseUser) {
    await _db.collection("users").add(user.toJson());
    return true;
  } else if (res is PlatformException)
    return res.message.toString();
  else
    return "Unknow Error Occured";
}

Future login(String email, String password) async {
  var user = await AuthService.loginWithEmail(email, password);
  print(user);
  if (user is FirebaseUser)
    return true;
  else if (user is PlatformException)
    return user.code != "ERROR_USER_NOT_FOUND"
        ? user.message
        : "Incorrect Email or Password";
  else
    return "Unknow Error Occured";
}

bool logout() {
  var user = AuthService.logout();
  print(user);
  return true;
}

Future getCurrentUser() async {
  return await AuthService.getCurrentUser();
}
