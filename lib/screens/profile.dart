import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
 String userName,email,password,mobileNumber='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){ AppRoutes.replace(context,Routes.All_Tabs);
          },
          child: Icon(
            Icons.arrow_back_ios
       ,color: Colors.black, ),
        ),
      title: Text('My Profile',style: TextStyle(color: Colors.black,fontSize: 20),),
        actions: [
          GestureDetector(
            onTap: (){
              AppRoutes.push(context,Routes.Settings);


            },
            child: Icon(
              Icons.settings,color: Colors.blue,
            ),
          )

        ],
      ),
      body: Container(
        width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [

          Container(
            margin: EdgeInsets.only(top: 20),
          width: 150,
            height: 150,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle
                ,border: Border.all(
              color: Color(0xffEAEEFF),
            width: 5
            ),
            ),
          child: Image.asset('assets/images/person.png',scale: 3.5,),
          ),
        SizedBox(
          height: 20,
        ),
          Column(
            children: [
              new Row(
                children: [
                  Text('User Name',style: TextStyle(fontSize: 18),),
                  Text('   *',style: TextStyle(color: red),)
                ],
              ),
              Container(
                width: SizeConfig.screenWidth,
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                padding:EdgeInsets.only(top: 10,left: 15) ,
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
              child:  new Container(
                width: SizeConfig.screenWidth * .7,
                decoration: BoxDecoration(),
                padding:
                const EdgeInsets.only(left: 0.0, right: 10.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      child: TextFormField(
                        onChanged: (val) => {userName = val},
                        validator: (value) {
                          if (value.isEmpty ) {
                            return 'Please enter a valid username';
                          }
                          return null;
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'john@gmail.com',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),

            ],
          ),
          Column(
            children: [
              new Row(
                children: [
                  Text('Email ID',style: TextStyle(fontSize: 18),),
                  Text('   *',style: TextStyle(color: red),)
                ],
              ),
              Container(
                width: SizeConfig.screenWidth,
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                padding:EdgeInsets.only(top: 10,left: 15) ,
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
                child: new Container(
                  width: SizeConfig.screenWidth * .7,
                  decoration: BoxDecoration(),
                  padding:
                  const EdgeInsets.only(left: 0.0, right: 10.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child: TextFormField(
                          onChanged: (val) => {email = val},
                          validator: (value) {
                            if (value.isEmpty ||
                                !EmailValidator.validate(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'john@gmail.com',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
          Column(
            children: [
              new Row(
                children: [
                  Text('Password',style: TextStyle(fontSize: 18),),
                  Text('   *',style: TextStyle(color: red),)
                ],
              ),
              Container(
                width: SizeConfig.screenWidth,
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                padding:EdgeInsets.only(top: 10,left: 15) ,
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Container(
                      width: SizeConfig.screenWidth * .6,
                      decoration: BoxDecoration(),
                      padding:
                      const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                            child: TextFormField(
                              onChanged: (val) => {password = val},
                              validator: (value) {
                                if (value.isEmpty ) {
                                  return 'Please enter a valid password';
                                }
                                return null;
                              },
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '**************',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _changePassword,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5,right: 10),
                        width: 60,
                        height: 30,

                        decoration: BoxDecoration(
                          color: green,
                          borderRadius: BorderRadius.all(Radius.circular(10)),


                        ),
                     child: Center(child: Text('Change',style: TextStyle(color: Colors.white),),),
                      ),

                    )
                  ],
                ),
              ),

            ],
          ),
          Column(
            children: [
              new Row(
                children: [
                  Text('Mobile Number',style: TextStyle(fontSize: 18),),
                  Text('   *',style: TextStyle(color: red),)
                ],
              ),
              Container(
                width: SizeConfig.screenWidth,
                height: 40,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                padding:EdgeInsets.only(top: 10,left: 15) ,
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),
                child: new Container(
                  width: SizeConfig.screenWidth * .7,
                  decoration: BoxDecoration(),
                  padding:
                  const EdgeInsets.only(left: 0.0, right: 10.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child: TextFormField(
                          onChanged: (val) => {mobileNumber = val},
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '+44 1234564789',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ),

            ],
          ),

          GestureDetector(
            onTap:_logOut,
            child: Container(
              width: SizeConfig.screenWidth,
              height: 45,
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              padding:EdgeInsets.only(top: 5,left: 15) ,
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.all(Radius.circular(10)),

              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   Image.asset('assets/images/logout.png',scale: 2.5,),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('LogOut',style: TextStyle(fontSize: 18,color: Colors.white),),

                    )
                  ],
                ),
              ),
            ),
          ),

        ],

      ),
      ),


    );
  }
  void _logOut(){}
 void _changePassword(){}
}
