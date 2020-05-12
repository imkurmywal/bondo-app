import 'package:bondo/screens/mainscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bondo/screens/profile.dart';
import 'package:bondo/screens/notification.dart';
import 'package:bondo/screens/voice_Message.dart';

class AllTabs extends StatefulWidget {
  @override
  _AllTabsState createState() => _AllTabsState();
}

class _AllTabsState extends State<AllTabs> with SingleTickerProviderStateMixin{
  int page = 0;
  TabController _tabController;
  PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          bottomNavigationBar: TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.blue,
            tabs: [
              new Tab( icon: Icon(Icons.home),
              ),
              new Tab(
                icon: new Icon(Icons.chat),
              ),

              new Tab(
                icon: new Icon(Icons.notifications),
              ),
              new Tab(
                icon: new Icon(Icons.person),
              ),
            ],

            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,),
        body:TabBarView(
            children: [
              MainScreen(),
              VoiceMessage(),
              Notifications(),
              Profile(),

            ],
            controller: _tabController,),

      ),
    );
  }
}
