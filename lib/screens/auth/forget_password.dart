import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool sendpassword = false;
  String forgotEmail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.1),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .9,
          height: MediaQuery.of(context).size.height * .4,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(26))),
          child: Column(
            children: [
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10, top: 20),
                    child: GestureDetector(
                      onTap: () {
                        AppRoutes.pop(context);
                      },
                      child: Icon(Icons.clear),
                    ),
                  )
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text(
                "Forget Password",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Container(
                width: MediaQuery.of(context).size.width * .8,
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
                      width: MediaQuery.of(context).size.width * .65,
                      decoration: BoxDecoration(),
                      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                            child: TextFormField(
                              onChanged: (val) => {forgotEmail = val},
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
                                hintText: 'E-mail',
                                hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: sendpassword == false
                      ? Text(
                          'Please enter your email id',
                          style: TextStyle(
                              color: red, fontWeight: FontWeight.w400),
                        )
                      : Text(
                          'new password sent to you mail',
                          style: TextStyle(
                              color: green, fontWeight: FontWeight.w400),
                        )),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              GestureDetector(
                onTap: () {
                  setState(() {
                    sendpassword = true;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  height: MediaQuery.of(context).size.height * .06,
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
                        'Send',
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
            ],
          ),
        ),
      ),
    );
  }
}
