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
        Routes.MAP_SCREEN: (context) => MapScreen(),
        Routes.VOICE_MESSAGES: (context) => VoiceMessage(),
        Routes.NOTIFICATIONS: (context) => Notifications(),
        Routes.PROFILE: (context) => Profile(),
        Routes.SETTINGS: (context) => Setting(),
      },
    ));
  });
}
