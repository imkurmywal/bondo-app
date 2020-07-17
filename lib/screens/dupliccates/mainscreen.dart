import 'dart:async';

import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_timer/flutter_timer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool recording = false;
  Recording _recording = new Recording();
  bool running = false, send = false;
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _drawer(),
      body: Stack(
        children: [
          Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: GoogleMap(
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: SizeConfig.screenWidth - 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState.openDrawer();
                        },
                        child: Icon(Icons.sort),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search),
                            Text('Search here'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        child: Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () {},
                      child: Image.asset(
                        'assets/images/filter.png',
                        scale: 4,
                      )),
                  InkWell(
                      onTap: () {},
                      child: Image.asset(
                        'assets/images/location.png',
                        scale: 4,
                      )),
                  InkWell(
                      onTap: () {
                        setState(() {
                          running = true;
                          recording = true;
                        });
                      },
                      child: Image.asset(
                        'assets/images/record.png',
                        scale: 4,
                      )),
                ],
              ),
            ),
          ),
          recording == true
              ? Align(
                  alignment: Alignment.bottomCenter, child: _recordingPart())
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _recordingPart() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: SizeConfig.screenWidth,
      height: SizeConfig.blockSizeVertical * 30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: Colors.white),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            'Voice Recording...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: 10, right: SizeConfig.blockSizeHorizontal * 25),
                  child: Text(
                    'Timer',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  )),
              Container(
                margin:
                    EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 20),
                width: SizeConfig.blockSizeHorizontal * 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TikTikTimer(
                      initialDate: DateTime.now(),
                      running: running,
                      height: 50,
                      width: 100,
                      backgroundColor: Colors.white,
                      timerTextStyle:
                          TextStyle(color: Colors.black, fontSize: 20),
                      borderRadius: 100,
                      isRaised: false,
                      tracetime: (time) {
                        // print(time.getCurrentSecond);
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 10,
                    ),
                    send == false
                        ? GestureDetector(
                            onTap: _stop,
                            child: CircleAvatar(
                              backgroundColor: red,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ))
                        : GestureDetector(
                            onTap: _send,
                            child: CircleAvatar(
                                backgroundColor: green,
                                child: Image.asset(
                                  'assets/images/send.png',
                                  scale: 5,
                                )),
                          ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 2,
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Title:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 2,
              ),
              new Container(
                width: SizeConfig.screenWidth * .9,
                decoration: BoxDecoration(),
                padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                child: TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    hintText: "My opinion about Heliopolis streets renovation",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _stop() {
    setState(() {
      running = false;
      send = true;
    });
  }

  void _send() {
    setState(() {
      recording = false;
      send = false;
    });
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

  Widget _drawer() {
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
                    onTap: () {},
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
    );
  }

  void _logOut() {}
}
