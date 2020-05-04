import 'package:flutter/material.dart';

Widget MySnackBar(
    {@required context,
    text = "I am Snackbar",
    color = Colors.black,
    time = 3}) {
  Scaffold.of(context).showSnackBar(SnackBar(
    backgroundColor: color,
    content: Text(text),
    duration: Duration(seconds: time),
  ));
}
