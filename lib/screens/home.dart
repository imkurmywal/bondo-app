import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.fill,
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
              _getStartedWidget()
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
            onTap: () {},
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
            onTap: () {},
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
      ],
    );
  }

  Widget _getStartedWidget() {
    return Container(
      width: SizeConfig.screenWidth,
      height: SizeConfig.blockSizeVertical * 20,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
//                AppRoutes.push(context, Routes.MAP_SCREEN);
                AppRoutes.push(context, Routes.SIGN_UP);
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
                      'Get Started',
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
            Column(
              children: [
                Text(
                  'By continuing  you agree that you have read and accept our',
                  style: TextStyle(fontSize: 12),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Terms of Services ',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 12)),
                    Text('and', style: TextStyle(fontSize: 12)),
                    Text(' Privacy Policy',
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 12))
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
