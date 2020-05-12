import 'package:bondo/config/size_config.dart';
import 'package:bondo/screens/all_tabview.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:bondo/view_model/user/login_view_model.dart';
import 'package:bondo/widgets/MySnackbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LoginViewModel(),
        child: Scaffold(
          body: LoginPage(),
        ));
  }
}

class LoginPage extends StatelessWidget {
  String email, password, forgetEmail;
  bool sendpassword = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: Provider.of<LoginViewModel>(context).isLoading,
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
        ),
      ),
    );
  }

  Widget _backCard(context) {
    return Container(
      width: SizeConfig.screenWidth,
      height: SizeConfig.blockSizeVertical * 66,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: _loginCard(context)),
    );
  }

  Widget _loginCard(context) {
    return Builder(
        builder: (context) => Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.screenHeight * 0.01),
                  Text(
                    "Sign In",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
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
                          width: SizeConfig.screenWidth * .7,
                          decoration: BoxDecoration(),
                          padding:
                              const EdgeInsets.only(left: 0.0, right: 10.0),
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
                          width: SizeConfig.screenWidth * .7,
                          decoration: BoxDecoration(),
                          padding:
                              const EdgeInsets.only(left: 0.0, right: 10.0),
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
                                  obscureText:
                                      Provider.of<LoginViewModel>(context)
                                          .isObscure,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                    suffix: GestureDetector(
                                        onTap: () {
                                          Provider.of<LoginViewModel>(context,
                                                      listen: false)
                                                  .isObscure =
                                              !Provider.of<LoginViewModel>(
                                                      context,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(right: 10, left: 0, top: 10),
                          child: GestureDetector(
                              onTap: () {
                                AppRoutes.push(context, Routes.FORGET_PASSWORD);
                              },
                              child: Text(
                                'Forgot password',
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              )))
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      loginAction(context);
                    },
                    child: Container(
                      height: SizeConfig.screenHeight * .06,
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
                      Text('Dont have an acount? '),
                      GestureDetector(
                          onTap: () {
                            AppRoutes.replace(context, Routes.SIGN_UP);
                          },
                          child: Text(
                            'Create an account',
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
            ));
  }

  Widget _logoView(context) {
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

  Future<void> loginAction(context) async {
    if (_formKey.currentState.validate()) {
      final provider = Provider.of<LoginViewModel>(context, listen: false);

      provider.isLoading = true;

      await provider.login(email: email, password: password);

      if (provider.onSuccess != null) {
        if (!provider.onSuccess) {
          MySnackBar(
              context: context,
              text: '${provider.responseMessage}',
              color: Colors.red);
        } else {
          AppRoutes.push(context, Routes.PHONE_VERIFICATION);
        }
      }
    }
  }
}
