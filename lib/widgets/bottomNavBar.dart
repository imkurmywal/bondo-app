import 'package:bondo/utils/routes.dart';
import 'package:fancy_bottom_bar/fancy_bottom_bar.dart';
import 'package:flutter/material.dart';

Widget bottomNavBar(BuildContext context, int pos) {
  return FancyBottomBar(
    selectedPosition: pos,
    selectedColor: Colors.blueAccent,
    indicatorColor: Colors.blueAccent,
    items: [
      FancyBottomItem(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.blueAccent),
        ),
        icon: Icon(
          Icons.home,
          color: Colors.blueAccent,
        ),
      ),
      FancyBottomItem(
        title: Text(
          'Messages',
          style: TextStyle(color: Colors.blueAccent),
        ),
        icon: Icon(
          Icons.chat,
          color: Colors.blueAccent,
        ),
      ),
      FancyBottomItem(
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.blueAccent),
        ),
        icon: Icon(
          Icons.notifications,
          color: Colors.blueAccent,
        ),
      ),
      FancyBottomItem(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.blueAccent),
        ),
        icon: Icon(
          Icons.person,
          color: Colors.blueAccent,
        ),
      ),
    ],
    onItemSelected: (index) {
      print(index);
      switch (index) {
        case 0:
          AppRoutes.replace(context, Routes.MAP_SCREEN);
//          Navigator.of(context).pushNamedAndRemoveUntil(
//              Routes.MAP_SCREEN, (Route<dynamic> route) => false);
          break;
        case 1:
          AppRoutes.replace(context, Routes.VOICE_MESSAGES);
//          Navigator.of(context).pushNamedAndRemoveUntil(
//              Routes.VOICE_MESSAGES, (Route<dynamic> route) => false);
          break;
        case 2:
          AppRoutes.replace(context, Routes.NOTIFICATIONS);
//          Navigator.of(context).pushNamedAndRemoveUntil(
//              Routes.NOTIFICATIONS, (Route<dynamic> route) => false);
          break;
        case 3:
          AppRoutes.replace(context, Routes.PROFILE);
//          Navigator.of(context).pushNamedAndRemoveUntil(
//              Routes.PROFILE, (Route<dynamic> route) => false);
          break;
      }
    },
  );
}
