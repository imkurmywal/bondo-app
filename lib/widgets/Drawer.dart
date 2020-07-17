import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final Function logOut;

  MyDrawer({@required this.logOut});

  @override
  Widget build(BuildContext context) {
    return _drawer(context);
  }

  Widget _drawer(context) {
    return Drawer(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: <Widget>[
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 5,
                ),
                _logoView(context),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 5,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      AppRoutes.push(context, Routes.PROFILE);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'My Profile',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 18),
                        )
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            'Rate',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 18),
                          )
                        ],
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.share,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            'Share',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 18),
                          )
                        ],
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.info,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'About Us',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 18),
                        )
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: this.logOut,
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
    );
  }

  Widget _logoView(context) {
    return Column(
      children: [
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 20),
              child: GestureDetector(
                onTap: () {
                  AppRoutes.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: fieldBackground,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
        Image.asset('assets/images/logo.png', color: Colors.blue, scale: 4),
        SizedBox(
          height: 10,
        ),
        Text(
          'Bondo',
          style: TextStyle(
            fontSize: 40,
            color: Colors.black,
          ),
        ),
        Text(
          'World’s local Mic',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        )
      ],
    );
  }
}
