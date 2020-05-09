import 'dart:async';

import 'package:bondo/config/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: GoogleMap(
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Align(alignment: Alignment.topCenter,
            child: Container(

              width: SizeConfig.screenWidth-50,
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
                    child:Icon(Icons.sort),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    child:new Row(
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
                    child:Icon(Icons.person,color: Colors.blue,),
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
                      onTap: (){},
                      child: Image.asset('assets/images/filter.png',scale: 4,)),
                  InkWell(
                      onTap: (){},
                      child: Image.asset('assets/images/location.png',scale: 4,)),
                  InkWell(
                      onTap: (){},
                      child: Image.asset('assets/images/record.png',scale: 4,)),

                ],
              ),
            ),

          )
        ],
      ),

    );
  }
}
