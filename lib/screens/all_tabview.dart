import 'package:bondo/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:bondo/screens/profile.dart';
import 'package:bondo/screens/notifications.dart';
import 'package:bondo/screens/voice_messages.dart';

class AllTabs extends StatefulWidget {
  @override
  _AllTabsState createState() => _AllTabsState();
}

class _AllTabsState extends State<AllTabs> with SingleTickerProviderStateMixin {
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
            new Tab(
              icon: Icon(Icons.home),
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
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        body: TabBarView(
          children: [
            MapScreen(),
            VoiceMessage(),
            Notifications(),
            Profile(),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}
