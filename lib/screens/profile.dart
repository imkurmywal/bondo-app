import 'dart:io';

import 'package:bondo/main.dart';
import 'package:bondo/screens/MyPostes.dart';
import 'package:bondo/screens/home.dart';
import 'package:bondo/widgets/bottomNavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as Path;
import 'favScreen.dart';
class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

Firestore firestore = Firestore.instance;

class _ProfileState extends State<Profile> {

  DocumentSnapshot doc;

  String userName, email, password, mobileNumber = '';

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  String imageUrl=null;
  String uid;
  File image;

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    print(uid);
  }

  Future _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    this.image = image;
    _cropImage();

  }

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

  String _uploadedFileURL;

  bool isLoading = false;

  setImage(String url) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('image', url);
  }

  Future uploadFile() async {
    setState(() {
      isLoading = true;
    });
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/${Path.basename(image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileURL = fileURL;
      imageUrl = fileURL;
      setState(() {
        Myimage = fileURL;
      });
      setImage(fileURL);
     uploadData();
    });
  }

  showSuccessDialog(){
    showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
        title: Text('Changes Saved'),
        actions: <Widget>[
          MaterialButton(onPressed: (){
            Navigator.pop(context);
          },child: Text('ok'),)

        ],
      );
    });
  }

  uploadData(){
    firestore
        .collection('users')
        .document(MyUid)
        .setData({
      'uid': MyUid,
      'userName': userName,
      'email': email,
      'mob': mobileNumber,
      'pic': imageUrl
    }, merge: true).then((value) {
      showSuccessDialog();
    });
    setState(() {
      isLoading = false;
    });
  }
  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: bottomNavBar(context, 3),
      appBar: AppBar(
        backgroundColor: Colors.white,
//        leading: GestureDetector(
//          onTap: (){
//            Navigator.pop(context);
//            // AppRoutes.pop(context);
//          },
//          child: Icon(
//            Icons.arrow_back_ios
//       ,color: Colors.black, ),
//        ),
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FavScreen()));
            },
            child: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),

          SizedBox(
            width: 10,
          ),

          GestureDetector(
            onTap: () {
              AppRoutes.push(context, Routes.Settings);
            },
            child: Icon(
              Icons.settings,
              color: Colors.blue,
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
              stream: firestore
                  .collection('users')
                  .document(MyUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(),);
                }


//                if (!snapshot.hasError) {
//                  return Column(
//                    children: [
//                      InkWell(
//                        onTap: _getImage,
//                        child: Container(
//                            margin: EdgeInsets.only(top: 20),
//                            width: 150,
//                            height: 150,
//                            decoration: BoxDecoration(
//                              color: Colors.white,
//                              shape: BoxShape.circle,
//                              border:
//                              Border.all(color: Color(0xffEAEEFF), width: 5),
//                            ),
//                            child: CircleAvatar(
//                              backgroundColor: Colors.white,
//                              backgroundImage: image != null ? FileImage(image) :  AssetImage(
//                                'assets/images/person.png',
//                              ),
//                            )),
//                      ),
//                      SizedBox(
//                        height: 20,
//                      ),
//                      Column(
//                        children: [
//                          new Row(
//                            children: [
//                              Text(
//                                'User Name',
//                                style: TextStyle(fontSize: 18),
//                              ),
//                              Text(
//                                '   *',
//                                style: TextStyle(color: red),
//                              )
//                            ],
//                          ),
//                          Container(
//                            width: SizeConfig.screenWidth,
//                            height: 40,
//                            margin:
//                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                            padding: EdgeInsets.only(top: 10, left: 15),
//                            decoration: BoxDecoration(
//                              color: fieldBackground,
//                              borderRadius: BorderRadius.all(Radius.circular(10)),
//                            ),
//                            child: new Container(
//                              width: SizeConfig.screenWidth * .7,
//                              decoration: BoxDecoration(),
//                              padding:
//                              const EdgeInsets.only(left: 0.0, right: 10.0),
//                              child: new Row(
//                                crossAxisAlignment: CrossAxisAlignment.center,
//                                mainAxisAlignment: MainAxisAlignment.start,
//                                children: <Widget>[
//                                  new Expanded(
//                                    child: TextFormField(
//                                      controller: userNameController,
//                                      onChanged: (val) => {userName = val},
//                                      validator: (value) {
//                                        if (value.isEmpty) {
//                                          return 'Please enter a valid username';
//                                        }
//                                        return null;
//                                      },
//                                      textAlign: TextAlign.left,
//                                      decoration: InputDecoration(
//                                        border: InputBorder.none,
//                                        hintText: 'john@gmail.com',
//                                        hintStyle: TextStyle(color: Colors.grey),
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ),
//                        ],
//                      ),
//                      Column(
//                        children: [
//                          new Row(
//                            children: [
//                              Text(
//                                'Email ID',
//                                style: TextStyle(fontSize: 18),
//                              ),
//                              Text(
//                                '   *',
//                                style: TextStyle(color: red),
//                              )
//                            ],
//                          ),
//                          Container(
//                            width: SizeConfig.screenWidth,
//                            height: 40,
//                            margin:
//                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                            padding: EdgeInsets.only(top: 10, left: 15),
//                            decoration: BoxDecoration(
//                              color: fieldBackground,
//                              borderRadius: BorderRadius.all(Radius.circular(10)),
//                            ),
//                            child: new Container(
//                              width: SizeConfig.screenWidth * .7,
//                              decoration: BoxDecoration(),
//                              padding:
//                              const EdgeInsets.only(left: 0.0, right: 10.0),
//                              child: new Row(
//                                crossAxisAlignment: CrossAxisAlignment.center,
//                                mainAxisAlignment: MainAxisAlignment.start,
//                                children: <Widget>[
//                                  new Expanded(
//                                    child: TextFormField(
//                                      controller: emailController,
//                                      onChanged: (val) => {email = val},
//                                      validator: (value) {
//                                        if (value.isEmpty ||
//                                            !EmailValidator.validate(value)) {
//                                          return 'Please enter a valid email';
//                                        }
//                                        return null;
//                                      },
//                                      textAlign: TextAlign.left,
//                                      decoration: InputDecoration(
//                                        border: InputBorder.none,
//                                        hintText: 'john@gmail.com',
//                                        hintStyle: TextStyle(color: Colors.grey),
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ),
//                        ],
//                      ),
//
//                      Column(
//                        children: [
//                          new Row(
//                            children: [
//                              Text(
//                                'Mobile Number',
//                                style: TextStyle(fontSize: 18),
//                              ),
//                              Text(
//                                '   *',
//                                style: TextStyle(color: red),
//                              )
//                            ],
//                          ),
//                          Container(
//                              width: SizeConfig.screenWidth,
//                              height: 40,
//                              margin: EdgeInsets.symmetric(
//                                  horizontal: 0, vertical: 10),
//                              padding: EdgeInsets.only(top: 10, left: 15),
//                              decoration: BoxDecoration(
//                                color: fieldBackground,
//                                borderRadius:
//                                BorderRadius.all(Radius.circular(10)),
//                              ),
//                              child: new Container(
//                                width: SizeConfig.screenWidth * .7,
//                                decoration: BoxDecoration(),
//                                padding:
//                                const EdgeInsets.only(left: 0.0, right: 10.0),
//                                child: new Row(
//                                  crossAxisAlignment: CrossAxisAlignment.center,
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    new Expanded(
//                                      child: TextFormField(
//                                        controller: mobileController,
//                                        onChanged: (val) => {mobileNumber = val},
//                                        validator: (value) {
//                                          if (value.isEmpty) {
//                                            return 'Please enter a valid number';
//                                          }
//                                          return null;
//                                        },
//                                        textAlign: TextAlign.left,
//                                        decoration: InputDecoration(
//                                          border: InputBorder.none,
//                                          hintText: '+44 1234564789',
//                                          hintStyle:
//                                          TextStyle(color: Colors.grey),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              )),
//                        ],
//                      ),
//
//                      GestureDetector(
//                        onTap: () {
//                          // AppRoutes.pushWithArguments(context, Routes.MYPOSTS,arguments: doc.data);
//                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MyPosts(doc: doc,)));
//                        },
//                        child: Container(
//                          width: SizeConfig.screenWidth,
//                          height: 45,
//                          margin:
//                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                          padding: EdgeInsets.only(top: 5, left: 15),
//                          decoration: BoxDecoration(
//                            color: Colors.orange,
//                            borderRadius: BorderRadius.all(Radius.circular(10)),
//                          ),
//                          child: Center(
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: [
//                                Icon(
//                                  Icons.message,
//                                  color: Colors.white,
//                                ),
//                                Padding(
//                                  padding: EdgeInsets.only(left: 10),
//                                  child: Text(
//                                    'My Posts',
//                                    style: TextStyle(
//                                        fontSize: 18, color: Colors.white),
//                                  ),
//                                )
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                      isLoading
//                          ? Center(
//                        child: CircularProgressIndicator(),
//                      )
//                          :  GestureDetector(
//                        onTap: () {
//                          saveChange();
//                        },
//                        child: Container(
//                          width: SizeConfig.screenWidth,
//                          height: 45,
//                          margin:
//                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                          padding: EdgeInsets.only(top: 5, left: 15),
//                          decoration: BoxDecoration(
//                            color: green,
//                            borderRadius: BorderRadius.all(Radius.circular(10)),
//                          ),
//                          child: Center(
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: [
//                                Icon(
//                                  Icons.save,
//                                  color: Colors.white,
//                                ),
//                                Padding(
//                                  padding: EdgeInsets.only(left: 10),
//                                  child: Text(
//                                    'Save Changes',
//                                    style: TextStyle(
//                                        fontSize: 18, color: Colors.white),
//                                  ),
//                                )
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                      GestureDetector(
//                        onTap: _logOut,
//                        child: Container(
//                          width: SizeConfig.screenWidth,
//                          height: 45,
//                          margin:
//                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                          padding: EdgeInsets.only(top: 5, left: 15),
//                          decoration: BoxDecoration(
//                            color: red,
//                            borderRadius: BorderRadius.all(Radius.circular(10)),
//                          ),
//                          child: Center(
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: [
//                                Image.asset(
//                                  'assets/images/logout.png',
//                                  scale: 2.5,
//                                ),
//                                Padding(
//                                  padding: EdgeInsets.only(left: 10),
//                                  child: Text(
//                                    'LogOut',
//                                    style: TextStyle(
//                                        fontSize: 18, color: Colors.white),
//                                  ),
//                                )
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  );
//                }
//


                final data = snapshot.data.data;

                userNameController.text = data['userName'] == null ? " " : data['userName'];
                emailController.text = data['email'] == null ? "": data['email'];
                mobileController.text = data['mob'] == null ? "" :data['mob'];

                imageUrl = data['pic'];

                doc = snapshot.data;
                return Column(
                  children: [
                    InkWell(
                      onTap: (){
                        showDialog(context: context,builder: (BuildContext context){
                          return AlertDialog(
                            title: Text('Upload Image From'),
                            actions: <Widget>[
                              MaterialButton(
                                color: Colors.blue,
                                shape: StadiumBorder(
                                ),
                                 onPressed: (){
                                   _getImage(ImageSource.gallery);
                                 },
                                child: Text('Gallery'),
                              ),
                              MaterialButton(
                                color: Colors.blue,
                                shape: StadiumBorder(
                                ),
                                onPressed: (){
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
                            border:
                                Border.all(color: Color(0xffEAEEFF), width: 5),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: image != null ? FileImage(image) : data['pic'] == null
                                ? AssetImage(
                                    'assets/images/person.png',
                                  )
                                : NetworkImage(data['pic']),
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
                            margin: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            padding: EdgeInsets.only(top: 10, left: 15),
                            decoration: BoxDecoration(
                              color: fieldBackground,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
                                      controller: mobileController,
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
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),

                    GestureDetector(
                      onTap: () {
                       // AppRoutes.pushWithArguments(context, Routes.MYPOSTS,arguments: doc.data);
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MyPosts(doc: doc,)));
                      },
                      child: Container(
                        width: SizeConfig.screenWidth,
                        height: 45,
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        padding: EdgeInsets.only(top: 5, left: 15),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.message,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  'My Posts',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    isLoading
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        :  GestureDetector(
                      onTap: () {
                        saveChange();
                      },
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
                              Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Save Changes',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _logOut,
                      child: Container(
                        width: SizeConfig.screenWidth,
                        height: 45,
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        padding: EdgeInsets.only(top: 5, left: 15),
                        decoration: BoxDecoration(
                          color: red,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logout.png',
                                scale: 2.5,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  'LogOut',
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
                );
              }),
        ),
      ),
    );
  }

  void _logOut() {
    FirebaseAuth.instance.signOut();
    logOutUid();
  }

  logOutUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', null);
    prefs.setString('image', null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }


  void saveChange() {
    userName = userNameController.text ;
    mobileNumber = mobileController.text;
    email = emailController.text;

  print('\n$userName\n$password\n$mobileNumber\n$email\n$imageUrl\n\n');
   image == null ? uploadData() : uploadFile();
  }
}
