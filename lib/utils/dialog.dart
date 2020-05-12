import 'package:flutter/material.dart';

import 'color.dart';
class CustomDialog extends StatelessWidget {
  final dialog = true;
  final double opacity;
  final Widget child;
  final Widget outerchild;
  final double height;
  CustomDialog(
      {@required this.height, this.outerchild, this.opacity, this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.4),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: dialog == false
                  ? 0
                  : MediaQuery.of(context).size.height * .964,
              width: MediaQuery.of(context).size.width,
              color: Colors.black.withOpacity(opacity == null ? 0.0 : opacity),
            ),
          ),
          AnimatedContainer(

              duration: Duration(milliseconds: 300),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width*.95,
              height: dialog == false ? 0 : height,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(26)
                      ),

                  color: Colors.white),
              child: child),
        ],
      ),
    );
  }
}
