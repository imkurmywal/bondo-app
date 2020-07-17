import 'package:flutter/material.dart';

class NativationPage extends StatefulWidget {

  String title;

  NativationPage(this.title);
  @override
  _NativationPageState createState() => _NativationPageState();
}

class _NativationPageState extends State<NativationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.title),
      ),
    );
  }
}
