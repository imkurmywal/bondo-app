import 'package:bondo/config/size_config.dart';
import 'package:bondo/model/user.dart';
import 'file:///C:/Users/TYB/Desktop/Work/Fiverr%20Adloo/adloo_bondo/lib/screens/auth/phone_verification.dart';
import 'package:bondo/services/phone_verification_service.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:bondo/view_model/user/signup_view_model.dart';
import 'package:bondo/widgets/MySnackbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SignUpViewModel(),
        child: Scaffold(
          body: SignUpPage(),
        ));
  }
}

class SignUpPage extends StatelessWidget {
  String fullName, email, password, number, confirmationCode;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: Provider.of<SignUpViewModel>(context).isLoading,
      child: Scaffold(
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
                _logoView(context),
                SizedBox(
                  height: 20,
                ),
                _backCard(context)
              ]),
        ),
      )),
    );
  }

  Widget _backCard(context) {
    return Container(
//      width: SizeConfig.screenWidth,
//      height: SizeConfig.blockSizeVertical * 85,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: _signUpCard(context)),
    );
  }

  Widget _signUpCard(context) {
    return Builder(
      builder: (context) => Form(
        key: _formKey,
        child: Column(
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
                            obscureText: Provider.of<SignUpViewModel>(context,
                                    listen: false)
                                .isObscure,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              suffix: GestureDetector(
                                  onTap: () {
                                    Provider.of<SignUpViewModel>(context,
                                                listen: false)
                                            .isObscure =
                                        !Provider.of<SignUpViewModel>(context,
                                                listen: false)
                                            .isObscure;
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
                          color: Colors.grey,
                          width: 0.5,
                          style: BorderStyle.solid),
                    ),
                  ),
                  child: CountryPicker(
                    showDialingCode:
                        true, //displays dialing code, false by default
                    showFlag: false,
                    showName: false, //displays country name, true by default
                    showCurrency: false, //eg. 'British pound'
                    showCurrencyISO: false, //eg. 'GBP'
                    onChanged: (Country country) {
                      Provider.of<SignUpViewModel>(context, listen: false)
                          .country = country;
                    },
                    selectedCountry:
                        Provider.of<SignUpViewModel>(context).country,
                  ),
                ),
                new Container(
                  width: SizeConfig.blockSizeHorizontal * 52,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                          style: BorderStyle.solid),
                    ),
                  ),
                  child: TextFormField(
                    onChanged: (val) => {number = val},
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Please enter a valid number';
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
            _signUpButton(context),
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
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    )),
                SizedBox(
                  width: 10,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _logoView(BuildContext context) {
    return Column(
      children: [
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                AppRoutes.pop(context);
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

  Widget _signUpButton(context) {
    return GestureDetector(
      onTap: () {
        signUpAction(context);
      },
      child: Container(
        height: SizeConfig.blockSizeVertical * 6,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)), color: green),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 5,
            ),
            Text(
              'Continue',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: whitecolor),
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
    );
  }

  signUpAction(context) async {
    if (_formKey.currentState.validate()) {
      final provider = Provider.of<SignUpViewModel>(context, listen: false);

      provider.isLoading = true;

      bool isExist = await provider.isEmailAlreadyExist(email: email);
      if (isExist) {
        MySnackBar(
            context: context,
            text: 'Account with same email already exist',
            color: Colors.red);
        provider.isLoading = false;
      } else {
        print('phone' + '+${provider.country.dialingCode.toString()}$number');
        final phoneVerificationResults = await AppRoutes.pushWithArguments(
            context, Routes.PHONE_VERIFICATION, arguments: {
          'phone': '+${provider.country.dialingCode.toString()}$number'
        });
        if (phoneVerificationResults as bool) {
          final user = User(
              name: fullName,
              email: email,
              phone: '+${provider.country.dialingCode.toString()}$number');

          await provider.createUser(user: user, password: password);

          if (provider.onSuccess != null) {
            if (!provider.onSuccess) {
              MySnackBar(
                  context: context,
                  text: '${provider.responseMessage}',
                  color: Colors.red);
            } else {
              print('Goto Welcome Page');
            }
          }
        }
      }
    }
  }
}
