import 'package:bondo/widgets/bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = 'john@gmail.com',
      email = 'john@gmail.com',
      password = '**********',
      mobileNumber = '+44 1234564789';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar(context, 3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            AppRoutes.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AppRoutes.push(context, Routes.SETTINGS);
            },
            child: Icon(
              Icons.settings,
              color: Colors.blue,
            ),
          )
        ],
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xffEAEEFF), width: 5),
                ),
                child: Image.asset(
                  'assets/images/person.png',
                  scale: 3.5,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  new Row(
                    children: [
                      Text(
                        'User Name',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '   *',
                        style: TextStyle(color: red),
                      )
                    ],
                  ),
                  Container(
                    width: SizeConfig.screenWidth,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    padding: EdgeInsets.only(top: 10, left: 15),
                    decoration: BoxDecoration(
                      color: fieldBackground,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(userName),
                  ),
                ],
              ),
              Column(
                children: [
                  new Row(
                    children: [
                      Text(
                        'Email ID',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '   *',
                        style: TextStyle(color: red),
                      )
                    ],
                  ),
                  Container(
                    width: SizeConfig.screenWidth,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    padding: EdgeInsets.only(top: 10, left: 15),
                    decoration: BoxDecoration(
                      color: fieldBackground,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(email),
                  ),
                ],
              ),
              Column(
                children: [
                  new Row(
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '   *',
                        style: TextStyle(color: red),
                      )
                    ],
                  ),
                  Container(
                    width: SizeConfig.screenWidth,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    padding: EdgeInsets.only(top: 10, left: 15),
                    decoration: BoxDecoration(
                      color: fieldBackground,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(password),
                        GestureDetector(
                          onTap: _changePassword,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5, right: 10),
                            width: 60,
                            height: 30,
                            decoration: BoxDecoration(
                              color: green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Center(
                              child: Text(
                                'Change',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  new Row(
                    children: [
                      Text(
                        'Mobile Number',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '   *',
                        style: TextStyle(color: red),
                      )
                    ],
                  ),
                  Container(
                    width: SizeConfig.screenWidth,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    padding: EdgeInsets.only(top: 10, left: 15),
                    decoration: BoxDecoration(
                      color: fieldBackground,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(mobileNumber),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _logOut,
                child: Container(
                  width: SizeConfig.screenWidth,
                  height: 45,
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  padding: EdgeInsets.only(top: 5, left: 15),
                  decoration: BoxDecoration(
                    color: red,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logout.png',
                          scale: 2.5,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'LogOut',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logOut() {}
  void _changePassword() {}
}
