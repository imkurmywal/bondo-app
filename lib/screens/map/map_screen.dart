import 'dart:async';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:bondo/widgets/Drawer.dart';
import 'package:bondo/widgets/bottomNavBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer/flutter_timer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../view_model/map/map_view_model.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MapViewModel(),
        child: Scaffold(
          body: MapScreenPage(),
        ));
  }
}

class MapScreenPage extends StatefulWidget {
  @override
  _MapScreenPageState createState() => _MapScreenPageState();
}

class _MapScreenPageState extends State<MapScreenPage> {
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
      bottomNavigationBar: bottomNavBar(context, 0),
      key: _scaffoldKey,
      drawer: MyDrawer(
        logOut: () {
          print('LOGOUT');
        },
      ),
      body: Stack(
        children: [
          Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: GoogleMap(
//              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
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
      height: SizeConfig.blockSizeVertical * 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: Colors.white),
      child: Column(
        children: [
          SizedBox(
            height: 20,
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
                      top: 10, right: SizeConfig.blockSizeHorizontal * 42),
                  child: Text(
                    'Timer',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  )),
              Container(
                margin:
                    EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 18),
                width: SizeConfig.blockSizeHorizontal * 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TikTikTimer(
                      initialDate: DateTime.now(),
                      running: running,
                      height: 50,
                      width: 150,
                      backgroundColor: Colors.white,
                      timerTextStyle:
                          TextStyle(color: Colors.black, fontSize: 40),
                      borderRadius: 100,
                      isRaised: false,
                      tracetime: (time) {
                        // print(time.getCurrentSecond);
                      },
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 5,
                    ),
                    send == false
                        ? Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: GestureDetector(
                                onTap: _stop,
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: red,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: GestureDetector(
                              onTap: _send,
                              child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: green,
                                  child: Image.asset(
                                    'assets/images/send.png',
                                    scale: 5,
                                  )),
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 2,
              ),
              Divider(),
              new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Title:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
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
}
