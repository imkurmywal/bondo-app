import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<String> type = [
  'Replayed',
  'posted',
  'Replayed',
  'posted',
    'Replayed',
    'posted',
  ];
  List<String> action = [
    'on your Voice Note',
    'your Voice Note',
    'on your Voice Note',
    'your Voice Note',
    'on your Voice Note',
    'your Voice Note',
    ];
  List<String> option = [
    '  streets renovation',' Heliopolis streets renovation',' Heliopolis streets renovation',' Heliopolis streets renovation',' Heliopolis streets renovation',' Heliopolis streets renovation',
  ];
  String location='Newyork,USA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            AppRoutes.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios
            ,color: Colors.black, ),
        ),
        title: Text('Notifications',style: TextStyle(color: Colors.black,fontSize: 20),),

      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height-170,
              child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (BuildContext context, index) =>_notification(index)),
            ),


          ],
        ),
      ),


    );
  }
  Widget _notification(int index) {
    return Container(
      height: SizeConfig.blockSizeVertical*10,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    padding: EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
    color:index==0 || index==1 ? Color(0xffF9F7F7):Colors.white,
    borderRadius: BorderRadius.all(
    Radius.circular(20),
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.black54.withOpacity(0.3),
    )
    ]),
     child: Stack(
       children: [
         Image.asset('assets/images/avatar.png',scale: 4,),

         Positioned(
           left: 35,
           child: Container(
               margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          width: SizeConfig.screenWidth,
             child: Wrap(
               children: [
                 Text(type[index]+' ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),),Text(action[index],style: TextStyle(fontSize: 13),),Text(' (My opinion about',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),Text(option[index]+')',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),),
               Padding(
                   padding: EdgeInsets.only(top: 5,left: 5),
                   child: Text('20 Min ago',style: TextStyle(fontSize: 10,color: Colors.grey),)),
                 Padding(
                     padding: EdgeInsets.only(left: 5,top: 20),
                     child: Icon(Icons.location_on,color: red,size: 15)),
                 Padding(
                     padding: EdgeInsets.only(left: 0,top: 25),
                     child: Text(location,style: TextStyle(fontSize: 8,color: Colors.grey),)),

               ]
             ),
           ),
         ),
       ],
     ),

    );}
}
