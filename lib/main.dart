import 'dart:async';

import 'package:bondo/fcmPage.dart';
import 'package:bondo/screens/MyPostes.dart';
import 'package:bondo/screens/auth/forget_password.dart';
import 'package:bondo/screens/auth/login.dart';
import 'package:bondo/screens/auth/phone_verification.dart';
import 'package:bondo/screens/auth/signup.dart';
import 'package:bondo/screens/home.dart';
import 'package:bondo/screens/map_screen.dart';
import 'package:bondo/screens/notifications.dart';
import 'package:bondo/screens/profile.dart';
import 'package:bondo/screens/profileFisrst.dart';
import 'package:bondo/screens/voice_messages.dart';
import 'package:bondo/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bondo/screens/setting.dart';
import 'package:bondo/screens/reply.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/size_config.dart';
import 'package:geolocator/geolocator.dart';

import 'fcmReply.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
 // SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

  String MyUid = null;
  String userName;
  String Mainaddress;
  String messagingToken;
  String Myimage;
  Position currentLocation;
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");


  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    messagingToken = prefs.get('token');
    Myimage = prefs.get('image');
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _goToDeeplyNestedView(String msg) {
    Navigator.push(navigatorKey.currentContext, MaterialPageRoute(builder: (_) => NativationPage(msg)));
  }

  showNotificationDialog(String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reply on your post $title '),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ok'),
              )
            ],
          );
        });
  }



  _configureFirebaseMessageing() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
            _goToDeeplyNestedView('onMessage');
      },
      onLaunch: (Map<String, dynamic> message) async {


        _goToDeeplyNestedView('Launch');
//        print('\n\n\n onLaunch from fcm \n $message\n\n\n\n');
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (BuildContext context) => FcmReply(
//                  title: message['data']['title'],
//                  uid: message['data']['uid'],
//                  address: message['data']['address'],
//                  docId: message['data']['docId'],
//                  noteUrl: message['data']['noteUrl'],
//                  pic: message['data']['pic'],
//                  token: message['data']['token'],
//                )));
      },
      onResume: (Map<String, dynamic> message) async {

        _goToDeeplyNestedView('onResumed');

//
//        print('\n\n\n ON resume from fcm \n $message\n\n\n\n');
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (BuildContext context) => FcmReply(
//                  title: message['data']['title'],
//                  uid: message['data']['uid'],
//                  address: message['data']['address'],
//                  docId: message['data']['docId'],
//                  noteUrl: message['data']['noteUrl'],
//                  pic: message['data']['pic'],
//                  token: message['data']['token'],
//                )));
      },

    );
  }


  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((value){
      MyUid = value.uid;
    });
    _configureFirebaseMessageing();
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: navigatorKey,
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      title: '',
      home: SplashScreen(),
      // home: uid != null ? MapScreen() : Home(),
      routes: {
        Routes.HOME: (context) => Home(),
        Routes.SIGN_UP: (context) => SignUp(),
        Routes.PHONE_VERIFICATION: (context) => PhoneVerification(),
        Routes.LOGIN: (context) => Login(),
        Routes.FORGET_PASSWORD: (context) => ForgetPassword(),
        Routes.Settings: (context) => Setting(),
        Routes.Reply: (context) => Reply(),
        Routes.MAP_SCREEN: (context) => MapScreen(),
        Routes.VOICE_MESSAGES: (context) => VoiceMessage(),
        Routes.NOTIFICATIONS: (context) => Notifications(),
        Routes.PROFILE: (context) => Profile(),
        Routes.FirstProfile: (context) => FirstProfile(),
        Routes.SETTINGS: (context) => Setting(),
        Routes.MYPOSTS: (context) => MyPosts(),
        //Routes.REPLIEDPOSTS: (context) => ReplliedPost(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((value){
      MyUid = value.uid;

    });
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
              MyUid != null ? MapScreen() : Home()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(76, 123, 254, 1),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'Bondo',
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
