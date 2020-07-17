import 'dart:io';

import 'package:bondo/screens/getStartedPage.dart';
import 'package:bondo/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:path/path.dart' as Path;

class FirstProfile extends StatefulWidget {
  String uid;
  String img;
  String name;
  String email;
  String phone;
  FirstProfile({this.uid, this.img, this.name, this.email, this.phone});
  @override
  _FirstProfileState createState() => _FirstProfileState();
}

Firestore firestore = Firestore.instance;
String token;

class _FirstProfileState extends State<FirstProfile> {
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        image = croppedFile;
      });

      Navigator.pop(context);
    }
  }

  setProfileImage(String image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('image', image);
    print('\n\n$image\n profile image in set method\n\n');
  }

  setName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
  }

  setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    print(token);
  }

  FirebaseMessaging messaging = FirebaseMessaging();

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  String userName, email, password, mobileNumber = '';
  File image = null;
  bool isLoading = false;

  storeUid(String uid) async {
    print('\n\n\n\nuid ${uid}\n\n\n');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
  }

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    storeUid(widget.uid);

    messaging.getToken().then((deviceToken) {
      if (deviceToken != null) {
        setToken(deviceToken);
        token = deviceToken;
      }
    });
    if (widget.email != null) {
      emailController.text = widget.email;
    }
    if (widget.phone != null) {
      phoneController.text = widget.phone;
    }
    if (widget.name != null) {
      userNameController.text = widget.name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Form(
            key: formState,
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Upload Image From'),
                            actions: <Widget>[
                              MaterialButton(
                                color: Colors.blue,
                                shape: StadiumBorder(),
                                onPressed: () {
                                  _getImage(ImageSource.gallery);
                                },
                                child: Text('Gallery'),
                              ),
                              MaterialButton(
                                color: Colors.blue,
                                shape: StadiumBorder(),
                                onPressed: () {
                                  _getImage(ImageSource.camera);
                                },
                                child: Text('Camera'),
                              ),
                            ],
                          );
                        });
                  },
                  child: Container(
                      margin: EdgeInsets.only(top: 20),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xffEAEEFF), width: 5),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: image == null
                            ? widget.img != null
                                ? NetworkImage(widget.img)
                                : AssetImage('assets/images/person.png')
                            : FileImage(image, scale: 3.5)

//                            : widget.img != null ? NetworkImage(widget.img,) : image == null
//                            ? AssetImage(
//                                  'assets/images/person.png',
//                              )
//                            : FileImage(
//                                image,
//                                scale: 3.5,
//                              )
                        ,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    new Row(
                      children: [
                        Text(
                          'User Name',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '   *',
                          style: TextStyle(color: red),
                        )
                      ],
                    ),
                    Container(
                      width: SizeConfig.screenWidth,
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      padding: EdgeInsets.only(top: 10, left: 15),
                      decoration: BoxDecoration(
                        color: fieldBackground,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: new Container(
                        width: SizeConfig.screenWidth * .7,
                        decoration: BoxDecoration(),
                        padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Expanded(
                              child: TextFormField(
                                controller: userNameController,
                                onChanged: (val) => {userName = val},
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter a valid username';
                                  }
                                  return null;
                                },
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'john',
                                  errorStyle:
                                      TextStyle(height: -0, color: Colors.red),
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
                        Text(
                          'Email ID',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '   *',
                          style: TextStyle(color: red),
                        )
                      ],
                    ),
                    Container(
                      width: SizeConfig.screenWidth,
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      padding: EdgeInsets.only(top: 10, left: 15),
                      decoration: BoxDecoration(
                        color: fieldBackground,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: new Container(
                        width: SizeConfig.screenWidth * .7,
                        decoration: BoxDecoration(),
                        padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Expanded(
                              child: TextFormField(
                                controller: emailController,
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
                                  errorStyle:
                                      TextStyle(height: -0, color: Colors.red),
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
                        Text(
                          'Mobile Number',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '   *',
                          style: TextStyle(color: red),
                        )
                      ],
                    ),
                    Container(
                        width: SizeConfig.screenWidth,
                        height: 40,
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        padding: EdgeInsets.only(top: 10, left: 15),
                        decoration: BoxDecoration(
                          color: fieldBackground,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: new Container(
                          width: SizeConfig.screenWidth * .7,
                          decoration: BoxDecoration(),
                          padding:
                              const EdgeInsets.only(left: 0.0, right: 10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            onChanged: (val) => {mobileNumber = val},
                            validator: validateMobile,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              errorStyle:
                                  TextStyle(height: -0, color: Colors.red),
                              hintText: '+44 1234564789',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )),
                  ],
                ),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : GestureDetector(
                        onTap: AuthAndSubmit,
                        child: Container(
                          width: SizeConfig.screenWidth,
                          height: 45,
                          margin:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                          padding: EdgeInsets.only(top: 5, left: 15),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //  Image.asset('assets/images/logout.png',scale: 2.5,),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Save Profile',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    }

    return null;
  }

  logOutUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }

  AuthAndSubmit() {
    if (!formState.currentState.validate()) {
      return;
    }
    if (image == null && widget.img == null) {
      Toast.show("Please select an image", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return;
    }

    uploadFile();
  }

  String _uploadedFileURL;

  Future uploadFile() async {
    setState(() {
      isLoading = true;
    });

    if (image != null) {
      print('\n\n\ni am in the if part\n\n');

      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('users/${Path.basename(image.path)}}');
      StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      print('File Uploaded');
      storageReference.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;
        print('\n\n $_uploadedFileURL \n');
        firestore.collection('users').document(widget.uid).setData({
          'uid': widget.uid,
          'userName': userNameController.text,
          'email': emailController.text,
          'mob': phoneController.text,
          'pic': _uploadedFileURL,
        }).then((value) {
          setName(userName);
          setProfileImage(fileURL);
          firestore
              .collection('tokens')
              .add({'uid': widget.uid, 'token': token});
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => GetStarted(widget.uid)));
        }).whenComplete(() {
          setState(() {
            isLoading = false;
          });
        });
      });
    } else {
      print('\n\n\ni am in the else part ${widget.img}}\n\n');

      firestore.collection('users').document(widget.uid).setData({
        'uid': widget.uid,
        'userName': userNameController.text,
        'email': emailController.text,
        'mob': phoneController.text,
        'pic': widget.img,
      }).then((value) {
        setName(userName);
        setProfileImage(widget.img);
        firestore.collection('tokens').add({'uid': widget.uid, 'token': token});
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => GetStarted(widget.uid)));
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    this.image = image;

    _cropImage();
  }
}
