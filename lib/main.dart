import 'package:bondo/config/size_config.dart';
import 'package:bondo/screens/forget_password.dart';
import 'package:bondo/screens/home.dart';
import 'package:bondo/screens/login.dart';
import 'package:bondo/screens/phone_verification.dart';
import 'package:bondo/screens/signup.dart';
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
        Routes.All_Tabs: (context) => AllTabs(),
        Routes.Settings: (context) => Setting(),


      },
    ));
  });
}
