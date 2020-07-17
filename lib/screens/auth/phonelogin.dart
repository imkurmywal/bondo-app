import 'package:bondo/screens/auth/phoneverification.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneLogin extends StatefulWidget {
  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

double height, width;

class _PhoneLoginState extends State<PhoneLogin> {
  String phoneNo, mYcountryCode, fullPhone;
  String _hintText = '1234567';
  TextEditingController c = TextEditingController();

  //String smsCode;
  String verificationId;
  FirebaseAuth _auth;
  bool isLoading = false;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeSend]) {
      verificationId = verId;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
            return VarificationPage(verificationId, fullPhone);
          }));
    };

    final PhoneVerificationCompleted verificationSuccess =
        (AuthCredential u) async {
      AuthResult result = await _auth.signInWithCredential(u);
      FirebaseUser user = result.user;
      if (user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    VarificationPage(verificationId, fullPhone)));
      } else {}
    };

    final PhoneVerificationFailed verificationFailled =
        (AuthException exception) {
      print('\n\n\n');
      print('${exception.message}');
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        codeAutoRetrievalTimeout: null,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationSuccess,
        verificationFailed: verificationFailled);
  }

  Future<bool> loginUser(String phone, BuildContext context) async {
    //TextEditingController _codeController = TextEditingController();
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();

          AuthResult result = await _auth.signInWithCredential(credential);

          FirebaseUser user = result.user;

          if (user != null) {
           print('\n\n\n\n\nPhone Auth seccess\n\n\n\n\n\n\n');
          } else {
            print("\n\n\n\n\nPhone Auth Error\n\n\n\n");
            setState(() {
              isLoading = false;
            });
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception) {
          print(exception.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      VarificationPage(verificationId, fullPhone)));
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromRGBO(76, 123, 254, 1),
      body: SingleChildScrollView(
        child: Container(
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
                  child: Container(
                    child: TextField(
                      controller: c,
                      keyboardType: TextInputType.number,
                      onChanged: (input) {
                        phoneNo = input.trim();
                      },
                      decoration: InputDecoration(
                          hintText: _hintText,
                          hintStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.black.withOpacity(0.5)),
                          alignLabelWithHint: true,
                          prefixIcon: CountryCodePicker(
                            onChanged: _onCountryChange,
                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                            initialSelection: 'EG',
                            // optional. Shows only country name and flag
                            showCountryOnly: false,
                            // optional. Shows only country name and flag when popup is closed.
                            showOnlyCountryWhenClosed: false,
                            // optional. aligns the flag and the Text left
                            alignLeft: false,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder:  OutlineInputBorder(
                            borderSide:
                             BorderSide(color: Colors.blue, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: width * 0.1,
                ),
                MaterialButton(
                  onPressed: () {
                    print('called');
                    try {
                      fullPhone = mYcountryCode + phoneNo;
                      if (fullPhone.length  < 8) {
                        setState(() {
                          isLoading = true;
                        });
                      }
                      print('\n');
                      print('\n');
                      print('$fullPhone');
                      print('\n');
                      print('\n');
                      loginUser(fullPhone, context);
                    } catch (e) {
                      setState(() {
                        c.clear();
                        _hintText = 'Please enter correct phone number';
                        isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    width: width * 0.86,
                    height: 60,
                    child: isLoading == true
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : Center(
                        child: Text(
                          'Continue with Phone',
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    //TODO : manipulate the selected country code here
    print("New Country selected: " + countryCode.toString());
    mYcountryCode = countryCode.toString();
  }
}