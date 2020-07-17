import 'package:bondo/screens/map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otp_count_down/otp_count_down.dart';
import '../profileFisrst.dart';


class VarificationPage extends StatefulWidget {
  final String verId;
  String phoneNumber;

  VarificationPage(
      this.verId,
      this.phoneNumber
      );

  @override
  _VarificationPageState createState() => _VarificationPageState();
}

double height, width;

class _VarificationPageState extends State<VarificationPage> {
  String smsCode;

  bool isLoading = false;

  Future<bool> loginUser(String phone, BuildContext context) async {
    //TextEditingController _codeController = TextEditingController();
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          //     Navigator.of(context).pop();

          AuthResult result = await _auth.signInWithCredential(credential);

          FirebaseUser user = result.user;

          if (user != null) {

            print('\n\n\n\nPhone Auth Success\n\n\n\n');

            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> FirstProfile(
              uid: user.uid,
              img: user.photoUrl,
              email: user.email,
              name: user.displayName,
              phone: user.phoneNumber,
            )));

          } else {
            setState(() {
              isLoading = false;
            });
            print('\n\n\n\nPhone Auth Error\n\n\n\n\n');
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception) {
          setState(() {
            isLoading = false;
          });
          print(exception.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
        },
        codeAutoRetrievalTimeout: null);
  }


  String _countDown;
  OTPCountDown _otpCountDown;
  final int _otpTimeInMS = 1000 * 2 * 60;
  bool isTicking = true;

  void _startCountDown() {

    setState(() {
      isTicking = true;
    });
    print('Phone number in verification screen ${widget.phoneNumber}');
    loginUser(widget.phoneNumber, context);
    _otpCountDown = OTPCountDown.startOTPTimer(
      timeInMS: _otpTimeInMS,
      currentCountDown: (String countDown) {
        _countDown = countDown;
        setState(() {});
      },
      onFinish: () {
        print("Count down finished!");
        setState(() {
          isTicking = false;
        });
      },
    );
  }

  @override
  void initState() {
    _startCountDown();
    print('\n\n\nphone number from verification screen ${widget.phoneNumber}\n\n\n');
    super.initState();
  }



  @override
  void dispose() {
    _otpCountDown.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
       backgroundColor: Color.fromRGBO(76, 123, 254, 1),
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: height * 0.2,
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 200,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (input) {
                    smsCode = input.trim();
                  },
                  decoration: InputDecoration(
                      hintText: 'Enter verification code',
                      hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.5)),
                      alignLabelWithHint: true,
                      prefixIcon: Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Icon(
                            Icons.lock,
                            color: Colors.black,
                            size: 25,
                          )),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10)))),
                ),
              ),
              SizedBox(
                height: width * 0.1,
              ),
              MaterialButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  AuthCredential credential = PhoneAuthProvider.getCredential(
                      verificationId: widget.verId, smsCode: smsCode);

                  AuthResult result = await FirebaseAuth.instance
                      .signInWithCredential(credential);

                  FirebaseUser user = result.user;

                  if (user != null) {

                    print('\n\n\n\nPhone Auth Success\n\n\n\n\n');

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MapScreen())).then((e){

                    });
                  } else {
                    print('\n\n\n\nPhone Auth Error\n\n\n\n\n');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  width: width * 0.86,
                  height: 60,
                  child: Center(
                      child: isLoading == false ? Text(
                        'Continue',
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ) : CircularProgressIndicator(backgroundColor: Colors.white,)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: isTicking == true ? null : _startCountDown,
                      child: Text('Resend',style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _countDown == null ? '' : '$_countDown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.height * 0.04,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}