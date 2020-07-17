import 'package:bondo/config/size_config.dart';
import 'package:bondo/main.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:bondo/widgets/bottomNavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

Firestore firestore = Firestore.instance;

class _NotificationsState extends State<Notifications> {


  List<DocumentSnapshot> users = [];

  bool isLoading = true;



  String img = null;
  @override
  void initState() {
    firestore.collection('users').getDocuments().then((value){
      users = value.documents;
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar(context, 2),
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        child: isLoading ? Center(child: CircularProgressIndicator(),) :Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height - 170,
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('replies').where('uid',isEqualTo: MyUid).snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child:
                        Center(child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Text('No Notification Found',style: TextStyle(color: Colors.grey),)
                        ),)
                    );
                  }




                  final Data = snapshot.data.documents;
                  return Data.length ==0 ? Center(child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: Text('No Notification Found',style: TextStyle(color: Colors.grey),)
                  ),) :ListView.builder(
                      itemCount: Data.length,
                      itemBuilder: (BuildContext context, index) =>
                          _notification(Data[index]));
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notification(DocumentSnapshot doc) {

    print(users.length);
    DocumentSnapshot myDoc =  users.firstWhere((element) {
      return element.documentID == doc.data['uid'];
    });

    print(myDoc.data['pic']);

    String img = myDoc.data['pic'];




    return InkWell(
      onTap: (){
        print(doc.data['uid']);
      },
      child: Container(
        height: SizeConfig.blockSizeVertical * 10,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        padding: EdgeInsets.only(top: 20,left: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54.withOpacity(0.3),
              )
            ]),
        child: Stack(
          children: [

            SizedBox(
              width: 10,
            ),

            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: img == null? AssetImage(
                'assets/images/avatar.png',
              ) : NetworkImage(img),
            ),
            Positioned(
              left: 45,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                width: SizeConfig.screenWidth,
                child: Wrap(children: [
                  Text(
                   'Replayed ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'on your Voice Note',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(' (',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                   doc.data['title'] + ')',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
//                Padding(
//                    padding: EdgeInsets.only(top: 5, left: 5),
//                    child: Text(
//                      '20 Min ago',
//                      style: TextStyle(fontSize: 10, color: Colors.grey),
//                    )),

                ]),
              ),
            ),
            Container(

              margin: EdgeInsets.only(left: 42,),

              child: Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: 5, top: 20),
                      child: Icon(Icons.location_on, color: red, size: 15)),
                  Padding(
                      padding: EdgeInsets.only(left: 0, top: 25),
                      child: Text(
                        doc.data['address'],
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
