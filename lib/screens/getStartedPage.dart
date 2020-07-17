import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_screen.dart';

class GetStarted extends StatefulWidget {
  String uid;
  GetStarted(this.uid);
  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {


  final Permission _permission = Permission.locationWhenInUse;

  @override
  void initState(){
    _permission.request().then((value) {
       locateUser();
    });
    super.initState();
  }


  setLocation(double lat,double long)async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('lat', lat);
    prefs.setDouble('long', long);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Container(),

            Image.asset('assets/images/logo.png',height: 200,color: Colors.deepPurpleAccent,),

            _getStartedWidget(),
          ],
        ),
      ),
    );
  }

  Position location;
  Future<Position> locateUser() async {
     location =  await  Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return location;
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
                setLocation(location.latitude, location.longitude);
              //  AppRoutes.push(context, Routes.MAP_SCREEN);
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MapScreen()), (route) => false);
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

