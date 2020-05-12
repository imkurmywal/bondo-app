import 'package:bondo/utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bondo/utils/routes.dart';
import 'package:bondo/config/size_config.dart';
class Reply extends StatefulWidget {
  @override
  _ReplyState createState() => _ReplyState();
}

class _ReplyState extends State<Reply> {
 String name='John smith';
  int listnumber=0;
 String description='My opinion about Heliopolis streets renovation',location='Newyork,USA',distance='2.4';

 String duration='00:00';
 int timeplays=223,love=21,likes=124;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: (){ AppRoutes.pop(context);

            },

            child: Icon(
              Icons.arrow_back_ios
              ,color: Colors.black, ),
          ),
          title: Text('Reply',style: TextStyle(color: Colors.black,fontSize: 20),),

        ),
        body: Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            margin: EdgeInsets.symmetric(horizontal: 3),
            child: SingleChildScrollView(
              child: Column(
                  children: [
                    SizedBox(
                      height: SizeConfig.blockSizeVertical*5,
                    ),
                    Container(
                      height: SizeConfig.blockSizeVertical*45,
                      width: SizeConfig.screenWidth,
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      padding: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54.withOpacity(0.3),
                            )
                          ]),
                      child: Column(
                        children: [
                          _upperPart(listnumber),
                          Padding(padding: EdgeInsets.only(top: 5),
                            child: _play(),
                          ),

                          SizedBox(height: 10,),
                          _option(),
                        Divider(),
                        SizedBox(height: 10),
                        _replayPart(),

                        ],


                      ),

                    ),
                  ]
              ),
            )
        )
    );
  }
  Widget _replayPart(){
    return Column(
      children: [
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: SizeConfig.blockSizeHorizontal*2,

            ),
            CircleAvatar(
              backgroundColor: fieldBackground,
              maxRadius: 30,
            ),
            Padding(padding: EdgeInsets.only(left: 10,),
              child: Text(name,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            ),
          ],


        ),
        SizedBox(
          height: SizeConfig.blockSizeVertical*2,

        ),


        Container(
          width: SizeConfig.screenWidth-50,
          height: SizeConfig.blockSizeVertical*8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey)

          ),
          child: new Row(
            children: [
              new Container(
                width: SizeConfig.screenWidth * .65,
                decoration: BoxDecoration(),
                padding:
                const EdgeInsets.only(left: 0.0, right: 10.0),
                child:   TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    hintText: "My opinion about Heliopolis streets renovation",
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none

                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap:_send  ,
                child: Container(
                  width: SizeConfig.blockSizeHorizontal*17,
                  height: SizeConfig.blockSizeHorizontal*9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.blue


                  ),
                  child: Center(child: Text('Send',style: TextStyle(fontSize: 14,color: Colors.white,fontWeight:FontWeight.bold),)),
                ),
              )
            ],

          ),

        ),
      ],
    );
  }
 Widget _option(){
   return  new Row(
     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
     children: [
       new Row(
         children: [
           Icon(Icons.volume_up,color: Colors.blue,)
           ,Text(timeplays.toString())
         ],
       ),
       new Row(
         children: [
           Icon(Icons.share,color: Colors.grey,)
         ],
       ),
       new Row(
         children: [
           Image.asset('assets/images/love.png',scale: 3.5,)
           ,Padding(
               padding: EdgeInsets.only(left: 3),

               child: Text(love.toString()))
         ],
       ),
       new Row(
         children: [
           Image.asset('assets/images/like.png',scale: 3.5,)
           ,Padding(
               padding: EdgeInsets.only(left: 3),
               child: Text(likes.toString()))
         ],
       ),

       GestureDetector(
         onTap: (){
           AppRoutes.push(context,Routes.Reply);

         },
         child: new Container(
           width: SizeConfig.blockSizeHorizontal*20,
           height: 30,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.all(Radius.circular(5)),
             border: Border.all(width: 0.5,color: Colors.grey),

           ),
           child: new Row(
             mainAxisAlignment:MainAxisAlignment.center ,
             children: [
               Icon(Icons.reply,color: Colors.blue,size: 20,),
               Text('Reply')
             ],
           ),
         ),
       ),
     ],

   );

 }
 Widget _upperPart(int index){
   return Row(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Image.asset('assets/images/avatar.png',scale: 3.5,),
       Container(
           margin: EdgeInsets.only(left: 10,top: 0),
           width: SizeConfig.blockSizeHorizontal*50,
           child: Column(
             children: [
               Text(description),
               Padding(
                 padding: EdgeInsets.only(top: 5),
                 child: new Row(
                   children: [
                     Icon(Icons.location_on,color: red,size: 15),
                     Text(location,style: TextStyle(fontSize: 11,color: Colors.grey),)
                   ],
                 ),
               )

             ],
           )),
       SizedBox(
         width: 20,
       ),
       new Row(
         children: [
           Image.asset('assets/images/road.png',scale: 4,)
           ,Text(' '+distance+'Miles',style: TextStyle(fontSize: 13,color: Colors.grey)
           ) ],

       ),
       PopupMenuButton<int>(
         itemBuilder:  (context) => [
           PopupMenuItem(
             value: 1,
             child: Text(
               "Rename",
               style: TextStyle(
                   color: Colors.black, fontWeight: FontWeight.w400),
             ),
           ),
           PopupMenuItem(
             value: 2,
             child: Text(
               "Delete",
               style: TextStyle(
                   color: Colors.black, fontWeight: FontWeight.w400),
             ),
           ),
           PopupMenuItem(
             value: 3,
             child: Text(
               "Report",
               style: TextStyle(
                   color: Colors.black, fontWeight: FontWeight.w400),
             ),
           ),
         ],
         child: Icon(Icons.more_vert),
         onSelected: (value){
           if(value==1){
           }
           if(value==2){
           }
         },
       ),

     ],
   );
 }
 Widget _play(){
   return Container(
     width: SizeConfig.screenWidth-50,
     height: 40,

     decoration: BoxDecoration(
       color: fieldBackground,
       borderRadius: BorderRadius.all(Radius.circular(10)),
     ),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         GestureDetector(
           onTap:(){},
           child: Container(

             margin: EdgeInsets.only(bottom: 0,right: 10),
             width: 40,
             height: 20,

             decoration: BoxDecoration(
               color: Colors.blue,
               borderRadius: BorderRadius.all(Radius.circular(10)),


             ),
             child: Center(child: Icon(Icons.play_arrow,color: Colors.white,size: 20,),),
           ),

         )
         ,
         Padding(
             padding: EdgeInsets.only(right: 5),
             child: Text(duration)),

         Container(
           width: SizeConfig.screenWidth-180,
           child:LinearProgressIndicator(
             backgroundColor: Colors.grey,


           ),
         ),

         GestureDetector(
           onTap: (){


           },
           child: Icon(Icons.volume_down,color: Colors.blue,size: 25,),
         )
       ],
     ),

   );

 }
void _send(){}
}
