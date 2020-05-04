import 'package:flutter/material.dart';

class Routes {
  static const HOME = '/home';
  static const SIGN_UP = '/sign_up';
  static const PHONE_VERIFICATION = '/phone_verification';
  static const LOGIN = '/login';
  static const FORGET_PASSWORD = '/forget_password';
}

class AppRoutes {
  static void push(BuildContext context, String page) {
    Navigator.of(context).pushNamed(page);
  }

  static void replace(BuildContext context, String page) {
    Navigator.of(context).pushReplacementNamed(page);
  }

  static void makeFirst(BuildContext context, String page) {
    Navigator.of(context).popUntil((predicate) => predicate.isFirst);
    Navigator.of(context).pushReplacementNamed(page);
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void dismissAlert(context) {
    Navigator.of(context).pop();
  }
}
