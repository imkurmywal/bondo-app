import 'package:bondo/config/size_config.dart';
import 'package:bondo/screens/login.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String fullName, email, password, number, confirmationCode;
  bool obsure = true;
  Country _selected;
  bool confirmationBody = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 50,
                ),
                _logoView(),
                SizedBox(
                  height: 20,
                ),
                _backCard()
              ]),
        ),
      ),
    );
  }

  Widget _backCard() {
    return Container(
      width: SizeConfig.screenWidth,
      height: SizeConfig.blockSizeVertical * 72,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: _signUpCard()),
    );
  }

  Widget _signUpCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        Text(
          "Sign Up",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        Container(
          decoration: BoxDecoration(
            color: fieldBackground,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: new Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 5, left: 10),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  )),
              new Container(
                width: SizeConfig.blockSizeHorizontal * 70,
                decoration: BoxDecoration(),
                padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: TextFormField(
                        onChanged: (val) => {fullName = val},
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a valid input';
                          }
                          return null;
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          decoration: BoxDecoration(
            color: fieldBackground,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: new Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 5, left: 10),
                  child: Icon(
                    Icons.email,
                    color: Colors.blue,
                  )),
              new Container(
                width: SizeConfig.blockSizeHorizontal * 70,
                decoration: BoxDecoration(),
                padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: TextFormField(
                        onChanged: (val) => {email = val},
                        validator: (value) {
                          if (value.isEmpty ||
                              !EmailValidator.validate(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'sample@gmail.com',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          decoration: BoxDecoration(
            color: fieldBackground,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: new Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 5, left: 10),
                  child: Icon(
                    Icons.lock,
                    color: Colors.blue,
                  )),
              new Container(
                width: SizeConfig.blockSizeHorizontal * 70,
                decoration: BoxDecoration(),
                padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: TextFormField(
                        onChanged: (val) => {password = val},
                        validator: (value) {
                          if (value.isEmpty || value.length < 6) {
                            return 'Please enter atleast 6 digit password';
                          }
                          return null;
                        },
                        obscureText: obsure,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          suffix: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (obsure == false) {
                                    obsure = true;
                                  }
                                  if (obsure == true) {
                                    obsure = false;
                                  }
                                });
                              },
                              child: Icon(Icons.remove_red_eye)),
                          border: InputBorder.none,
                          hintText: 'password',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        new Row(
          children: [
            Padding(
                padding: EdgeInsets.only(right: 10, left: 0, top: 23),
                child: Icon(
                  Icons.phone,
                  color: Colors.blue,
                )),
            Container(
              margin: EdgeInsets.only(right: 10, left: 0, top: 23),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.grey, width: 0.5, style: BorderStyle.solid),
                ),
              ),
              child: CountryPicker(
                showDialingCode: true, //displays dialing code, false by default
                showFlag: false,
                showName: false, //displays country name, true by default
                showCurrency: false, //eg. 'British pound'
                showCurrencyISO: false, //eg. 'GBP'
                onChanged: (Country country) {
                  setState(() {
                    _selected = country;
                  });
                },
                selectedCountry: _selected,
              ),
            ),
            new Container(
              width: SizeConfig.blockSizeHorizontal * 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.grey, width: 0.5, style: BorderStyle.solid),
                ),
              ),
              child: TextFormField(
                onChanged: (val) =>
                    {number = _selected.dialingCode.toString() + val},
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a valid input';
                  }
                  return null;
                },
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '1234564789 ',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.only(top: 25, right: 15),
                ),
              ),
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15),
            child: Text(
                'By tapping sign up & accept , your acknowledge that you have read the privacy policy and agree to the terms.',
                style: TextStyle(color: Colors.grey))),
        GestureDetector(
          onTap: () {
            AppRoutes.push(context, Routes.PHONE_VERIFICATION);
          },
          child: Container(
            height: SizeConfig.blockSizeVertical * 6,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: green),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Continue',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: whitecolor),
                ),
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.navigate_next,
                      color: whitecolor,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(
          height: 5,
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Have an acount? '),
            GestureDetector(
                onTap: () {
                  AppRoutes.replace(context, Routes.LOGIN);
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                )),
            SizedBox(
              width: 10,
            ),
          ],
        )
      ],
    );
  }

  Widget _logoView() {
    return Column(
      children: [
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (confirmationBody == false) {
                  AppRoutes.pop(context);
                }
                if (confirmationBody == true) {
                  setState(() {
                    confirmationBody = false;
                  });
                }
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: whitecolor,
              ),
            )
          ],
        ),
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
}
