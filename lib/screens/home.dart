import 'package:bondo/config/size_config.dart';
import 'package:bondo/screens/auth/phonelogin.dart';
import 'package:bondo/screens/getStartedPage.dart';
import 'package:bondo/screens/profileFisrst.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bondo/utils/routes.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FacebookLogin fblogin = FacebookLogin();



    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = new GoogleSignIn();

    Future<FirebaseUser> signInWithGoogle() async {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult = await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      print(user.displayName.toString());
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      return user;
    }


  @override
  void initState() {
//    googleSignIn.onCurrentUserChanged.listen((account) {
//      handleSignIn(account);
//    }, onError: (e) {
//      print(e);
//    });

//    googleSignIn.signInSilently(suppressErrors: false).then((account) {
//      handleSignIn(account);
//    });
  }


//  final GoogleSignIn _googleSignIn = GoogleSignIn();
//  final FirebaseAuth _auth = FirebaseAuth.instance;


//  handleSignIn(GoogleSignInAccount account) async{
//    if (account != null) {
//      print('\n\nSuccess   ${account.id}\n\n\n');
//
////
////      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
////      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
////
////      final AuthCredential credential = GoogleAuthProvider.getCredential(
////        accessToken: googleAuth.accessToken,
////        idToken: googleAuth.idToken,
////      );
////
////      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
////    print("signed in " + user.displayName);
//
//      Navigator.push(context,
//          MaterialPageRoute(builder: (BuildContext context) => FirstProfile(
//            phone: null,
//            name: account.displayName,
//            email: account.email,
//            img: account.photoUrl,
//            uid: account.id,
//          )));
//    }
//  }

  storeUid(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 20,
              ),
              _logoView(),
              _socialButtons(),
              SizedBox(
                height: 20,
              ),
              //_getStartedWidget()
            ]),
      ),
    );
  }

  Widget _logoView() {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', scale: 4),
        SizedBox(
          height: 10,
        ),
        Text(
          'Bondo',
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
          ),
        ),
        Text(
          'World’s local Mic',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  Widget _socialButtons() {
    return new Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: () {
              fblogin.logIn(['email', 'public_profile']).then(
                  (FacebookLoginResult fbResult) {
                if (fbResult != null) {
                  // if facebook login result is loggedIn then
                  if (fbResult.status == FacebookLoginStatus.loggedIn) {
                    String facebookToken = fbResult.accessToken.token;

                    print("facebookToken is: ${facebookToken}");

                    AuthCredential credential =
                        FacebookAuthProvider.getCredential(
                            accessToken: facebookToken);

                    FirebaseAuth.instance
                        .signInWithCredential(credential)
                        .then((AuthResult authResult) {
                      AdditionalUserInfo userInfo =
                          authResult.additionalUserInfo;
//                      print("facebook userName is: ${userInfo.username}");
//                      print("facebook user profile is: ${userInfo.profile}");

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => FirstProfile(
                                    uid: authResult.user.uid,
                                    img: authResult.user.photoUrl,
                                    email: authResult.user.email,
                                    name: authResult.user.displayName,
                                    phone: authResult.user.phoneNumber,
                                  )));
                    }).catchError((error) {
                      print("error occurred while firebase tokenizing: $error");
                    });
                  }
                } else {
                  print("facebook login result is null");
                }
              }).catchError((e) {
                print(e);
                print('\n\n\n\no  External Error\n\n\n\n\n');
              });
            },
            child: Container(
              width:
                  SizeConfig.screenWidth - SizeConfig.blockSizeHorizontal * 20,
              height: SizeConfig.blockSizeVertical * 7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white),
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/facebook.png'),
                      maxRadius: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('Login With Facebook'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: GestureDetector(
            onTap: (){
            signInWithGoogle().then((account) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) => FirstProfile(
                    phone: null,
                    name: account.displayName,
                    email: account.email,
                    img: account.photoUrl,
                    uid: account.uid,
                  )));
            }) ;
    },
            child: Container(
              width: SizeConfig.screenWidth - 80,
              height: SizeConfig.blockSizeVertical * 7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/gmail.png'),
                    maxRadius: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('Login With Google'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PhoneLogin()));
            },
            child: Container(
              width: SizeConfig.screenWidth - 80,
              height: SizeConfig.blockSizeVertical * 7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.phone),
//                  CircleAvatar(
//                    child: Icon(Icons.phone),
//                    maxRadius: 15,
//                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('Login With Phone'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
