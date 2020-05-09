import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/routes.dart';
import 'package:flutter/material.dart';
class VoiceMessage extends StatefulWidget {
  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){AppRoutes.pop(context);
          },

          child: Icon(
          Icons.arrow_back_ios
          ,color: Colors.black, ),
        ),
    title: Text('Voice Message',style: TextStyle(color: Colors.black,fontSize: 20),),
       ),
    body: Container(
    width: SizeConfig.screenWidth,
    height: SizeConfig.screenHeight,
    ));}
}
