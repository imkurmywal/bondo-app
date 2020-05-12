import 'package:flutter/material.dart';

class Routes {
  static const HOME = '/home';
  static const SIGN_UP = '/sign_up';
  static const PHONE_VERIFICATION = '/phone_verification';
  static const LOGIN = '/login';
  static const FORGET_PASSWORD = '/forget_password';
/*<<<<<<< HEAD*/
  static const All_Tabs = '/all_tabview';
  static const Settings = '/setting';
  static const Reply = '/reply';

/*=======*/
  static const MAP_SCREEN = '/map_screen';
  static const VOICE_MESSAGES = '/voice_messages';
  static const NOTIFICATIONS = '/notifications';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
/*
>>>>>>> 1e053328800b8fc25f375ea0c4cd251c3569ecf8
*/
}

class AppRoutes {
  static void push(BuildContext context, String page) {
    Navigator.of(context).pushNamed(page);
  }

  static void pushWithArguments(BuildContext context, String page,
      {@required Map<String, dynamic> arguments}) {
    print("passing : ${arguments}");
    Navigator.of(context).pushNamed(page, arguments: arguments);
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
