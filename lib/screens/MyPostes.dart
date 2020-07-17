import 'package:bondo/screens/MyPosts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyPosts extends StatefulWidget {
  DocumentSnapshot doc;
  MyPosts({this.doc});
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: Text('My Posts',style: TextStyle(color: Colors.black),),
            centerTitle: true,
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  child: Text('Approved',style: TextStyle(color: Colors.black),),
                ),
                Tab(
                  child:Text('Pending',style: TextStyle(color: Colors.black),)
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Posts(true,widget.doc.data['pic']),
              Posts(false,widget.doc.data['pic'])
            ],
          ),
        ));
  }
}
