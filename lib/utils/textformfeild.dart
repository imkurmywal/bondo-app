import 'package:flutter/material.dart';

import 'color.dart';
class Textfeildclass extends StatefulWidget {
   String labletxt;
    Icon iconn;
    TextEditingController feildcontroller;
    TextInputType keyboardType;
    bool obscuretext=false;

Textfeildclass(
  {
  this.labletxt,
  this.iconn,
  this.feildcontroller,
  this.keyboardType,
    this.obscuretext,
}
);
 @override
  _TextfeildclassState createState() => _TextfeildclassState();
}


class _TextfeildclassState extends State<Textfeildclass> {
  
  
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22)
      ),
      elevation: 1,
      child: 
  
    Container(
      decoration: BoxDecoration(
        color:whitecolor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.grey.withOpacity(0.5),

          )

        ]
),
      height: MediaQuery.of(context).size.height/15,
      width:MediaQuery.of(context).size.width/1.7,
      child: TextFormField(
        obscureText: widget.obscuretext,
        keyboardType: widget.keyboardType,
        controller: widget.feildcontroller,
      decoration: InputDecoration(

        contentPadding: EdgeInsets.only(
        top: 15,
        left:20
        ),
        border: InputBorder.none,
      
          hintText:'${widget.labletxt}',
          hintStyle: TextStyle(
            color:Color(0xffC5C5C5),fontSize: 11,fontWeight: FontWeight.bold,
        ),
        suffixIcon: widget.iconn,
       
          )
        ),
      )  );
      
    
  }
}