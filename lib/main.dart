import 'package:bondo/config/size_config.dart';
import 'package:bondo/screens/forget_password.dart';
import 'package:bondo/screens/home.dart';
import 'package:bondo/screens/login.dart';
import 'package:bondo/screens/map_screen.dart';
import 'package:bondo/screens/notifications.dart';
import 'package:bondo/screens/phone_verification.dart';
import 'package:bondo/screens/profile.dart';
import 'package:bondo/screens/signup.dart';
import 'package:bondo/screens/voice_messages.dart';
import 'package:bondo/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bondo/screens/all_tabview.dart';
import 'package:bondo/screens/setting.dart';
import 'package:bondo/screens/reply.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MaterialApp(
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      title: '',
      home: Home(),
      routes: {
        Routes.HOME: (context) => Home(),
        Routes.SIGN_UP: (context) => SignUp(),
        Routes.PHONE_VERIFICATION: (context) => PhoneVerification(),
        Routes.LOGIN: (context) => Login(),
        Routes.FORGET_PASSWORD: (context) => ForgetPassword(),
/*<<<<<<< HEAD*/
        Routes.All_Tabs: (context) => AllTabs(),
        Routes.Settings: (context) => Setting(),
        Routes.Reply: (context) => Reply(),
/*=======*/
        Routes.MAP_SCREEN: (context) => MapScreen(),
        Routes.VOICE_MESSAGES: (context) => VoiceMessage(),
        Routes.NOTIFICATIONS: (context) => Notifications(),
        Routes.PROFILE: (context) => Profile(),
        Routes.SETTINGS: (context) => Setting(),
/*>>>>>>> *//*1e053328800b8fc25f375ea0c4cd251c3569ecf8
  */    },
    ));
  });
}
