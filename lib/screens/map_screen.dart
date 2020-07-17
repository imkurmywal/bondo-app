import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'package:bondo/fcmReply.dart';
import 'package:bondo/screens/auth/phonelogin.dart';
import 'package:bondo/screens/reply.dart';
import 'package:bondo/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bondo/screens/home.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:bondo/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file/local.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/widgets/Drawer.dart';
import 'package:bondo/widgets/bottomNavBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:toast/toast.dart';
import 'package:share/share.dart';
import '../fcmPage.dart';
import '../view_model/map/map_view_model.dart';

Firestore firestore = Firestore.instance;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MapViewModel(),
        child: Scaffold(
          body: MapScreenPage(),
        ));
  }
}

GlobalKey<FormState> formKey = GlobalKey<FormState>();

Future<dynamic> myBackgroundMessageHandler(
    Map<String, dynamic> message, BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
    return NativationPage(
        "this is from map ON Background ${message['data']['title']}");
  }));

  // Or do other work.
}

double diameter = 500;

enum PlayerState { stopped, playing, paused }

class MapScreenPage extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  MapScreenPage({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _MapScreenPageState createState() => _MapScreenPageState();
}

bool isTitleSearchCondition = true;

class _MapScreenPageState extends State<MapScreenPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(); // Create instance.
  AudioPlayer audioPlayer = AudioPlayer();
  bool recording = false;
  Recording _recording = new Recording();
  bool running = false, send = false;

  //Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _controller;

  String uid;

  //-------------------------------------------

  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  String imageUrl;
  bool isSearch = false;

  //-------------------------------------------

  String tags = null;
  String titleOfNote = null;
  Set<Marker> markers = Set<Marker>();
  DocumentSnapshot Note;

  Set<Circle> circles;

  getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    imageUrl = prefs.getString('image');
    print('\n\n\n$imageUrl\n\n');
  }

  String noteImage, noteAudioUrl, noteId, noteTitle;

  addMar({LatLng location, DocumentSnapshot doc}) {
    var markerIdVal = location.toString();

    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      icon: BitmapDescriptor.fromAsset("assets/images/vMarker.png"),
      markerId: markerId,
      position: location == null
          ? LatLng(37.42796133580664, -122.085749655962)
          : location,
      onTap: () {
        print(users.length);
        DocumentSnapshot myDoc = users.firstWhere((element) {
          return element.documentID == doc.data['uid'];
        });

        print(myDoc.data['pic']);

        String img = myDoc.data['pic'];

        setState(() {
          isMarkerClicked = true;
          Note = doc;
          noteImage = img;
          noteAudioUrl = doc.data['noteUrl'];
          noteTitle = doc.data['title'];
          noteId = doc.documentID;
        });
        //  _onMarkerTapped(markerId);
      },
    );

    // adding a new marker to map
    setState(() {
      markers.add(marker);
    });
  }

  Position currentLocation;

  FirebaseMessaging firebaseMessagingTOken = FirebaseMessaging();

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

//  addMyMarker(LatLng location) {
//    var markerIdVal = location.toString();
//
//    final MarkerId markerId = MarkerId(markerIdVal);
//
//
//    // creating a new MARKER
//    final Marker marker = Marker(
//      markerId: markerId,
//      position: location == null
//          ? LatLng(37.42796133580664, -122.085749655962)
//          : location,
//      infoWindow: InfoWindow(title: 'This is clickable marker', snippet: ''),
//      onTap: () {
//        setState(() {
//          isMarkerClicked = true;
//        });
//        // _onMarkerTapped(markerId);
//      },
//    );
//
//    // adding a new marker to map
//    markers.add(marker);
//  }

  Address address;
  String addressName;
  LatLng CurrentLatLng;

  getUserLocation() async {
    currentLocation = await locateUser();
    CurrentLatLng = CurrentLatLng == null
        ? LatLng(currentLocation.latitude, currentLocation.longitude)
        : CurrentLatLng;
    print('\n\n\n\n${currentLocation.longitude}\n\n\n\n\n\n');

    LatLng location = CurrentLatLng;
    //addMar(location: location);
//      _center = LatLng(currentLocation.latitude, currentLocation.longitude);

    LatLng latLng = CurrentLatLng;
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(latLng, 15);
    _controller.animateCamera(cameraUpdate);

    final coordinates =
        new Coordinates(CurrentLatLng.latitude, CurrentLatLng.longitude);
    List<Address> addresses;
    addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    address = addresses.first;
    //print("${address.featureName} : ${address.addressLine}");
    addressName = address.locality;
    Mainaddress = addressName;
    print(addressName);

    setState(() {
      circles = Set.from([
        Circle(
          circleId: CircleId(CurrentLatLng.latitude.toString()),
          center: CurrentLatLng,
          radius: diameter,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.white,
          strokeWidth: 2,
        )
      ]);
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(26.8206, 30.8025),
    zoom: 5,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isMarkerClicked = false;

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    MyUid = uid;
    userName = prefs.getString('name');
    LatLng positon = LatLng(prefs.getDouble('lat'), prefs.get('long'));
    CurrentLatLng = positon;
  }

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  TextEditingController searchController = TextEditingController();

  String currentTime = '00:00';
  String totalTime = '00:00';
  Duration currentDuration;
  double playPosition = 0;

//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//
//  _configureFirebaseMessageing() {
//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print('\n\n\n message from fcm  \n $message\n\n\n\n');
//        showNotificationDialog(message['data']['title']);
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//
//
//        print('\n\n\n onLaunch from fcm \n $message\n\n\n\n');
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (BuildContext context) => FcmReply(
//                  title: message['data']['title'],
//                  uid: message['data']['uid'],
//                  address: message['data']['address'],
//                  docId: message['data']['docId'],
//                  noteUrl: message['data']['noteUrl'],
//                  pic: message['data']['pic'],
//                  token: message['data']['token'],
//                )));
//      },
//      onResume: (Map<String, dynamic> message) async {
////        Navigator.push(context,
////            MaterialPageRoute(builder: (BuildContext context) {
////          return NativationPage(
////              "this is from map ON Resume ${message['data']['title']}");
////        }));
//
//        print('\n\n\n ON resume from fcm \n $message\n\n\n\n');
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (BuildContext context) => FcmReply(
//                  title: message['data']['title'],
//                  uid: message['data']['uid'],
//                  address: message['data']['address'],
//                  docId: message['data']['docId'],
//                  noteUrl: message['data']['noteUrl'],
//                  pic: message['data']['pic'],
//                  token: message['data']['token'],
//                )));
//      },
//
////      onLaunch: (Map<String, dynamic> message) async {
////        print('\n\n\n onLaunch from fcm \n $message\n\n\n\n');
////        Navigator.push(
////            context,
////            MaterialPageRoute(
////                builder: (BuildContext context) => FcmReply(
////                      title: message['data']['title'],
////                      uid: message['data']['uid'],
////                      address: message['data']['address'],
////                      docId: message['data']['docId'],
////                      noteUrl: message['data']['noteUrl'],
////                      pic: message['data']['pic'],
////                      token: message['data']['token'],
////                    )));
////      },
////      onResume: (Map<String, dynamic> message) async {
////        print('\n\n\n ON resume from fcm \n $message\n\n\n\n');
////        Navigator.push(
////            context,
////            MaterialPageRoute(
////                builder: (BuildContext context) => FcmReply(
////                      title: message['data']['title'],
////                      uid: message['data']['uid'],
////                      address: message['data']['address'],
////                      docId: message['data']['docId'],
////                      noteUrl: message['data']['noteUrl'],
////                      pic: message['data']['pic'],
////                      token: message['data']['token'],
////                    )));
////      },
//    );
//  }

  List<DocumentSnapshot> users;

  @override
  void initState() {
    firestore.collection('users').getDocuments().then((value) {
      users = value.documents;
    });

    getDocS(diameter);
    getUser();
    getUserLocation();
    getImage();
    _init();
    super.initState();

    //addMar(location: null);
    initAudioPlayer();

    if (messagingToken == null) {
      firebaseMessagingTOken.getToken().then((value) {
        messagingToken = value;
      });
    }

    //_configureFirebaseMessageing();
    audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.COMPLETED) {
        setState(() {
          currentTime = '00:00';
          position = Duration(seconds: 0);
          isPlayed = false;
        });
      }
    });

    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentDuration = duration;
        currentTime = duration.toString().split('.')[0];
      });
    });

    qurey = isTitleSearchCondition
        ? firestore
            .collection('notes')
            .where('isApproved', isEqualTo: true)
            .where('title', isEqualTo: searchController.text)
            .snapshots()
        : firestore
            .collection('notes')
            .where('isApproved', isEqualTo: true)
            .where('tag', arrayContains: searchController.text)
            .snapshots();
    //addMar1();
  }

  @override
  void dispose() async {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    _stopWatchTimer.dispose();
    super.dispose(); // Need to call dispose function.
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  File voiceNote;
  Stream<QuerySnapshot> qurey;

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording Duration: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    voiceNote = file;
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
  }

  showSuccessDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your post is uploaded and it\'s under review.'),
            content: Text(
                'To check your Post go to Profile > My Posts > Pending Posts.'),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ok'),
              )
            ],
          );
        });
  }

  showNotificationDialog(String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reply on your post ( $title )'),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ok'),
              )
            ],
          );
        });
  }

  String downloadUrl;

  uploadVoiceNote(File file) async {
    setState(() {
      isLoading = true;
    });
    Navigator.pop(context);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('voices/${Path.basename(file.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        isLoading = false;
      });
      showSuccessDialog();
      downloadUrl = fileURL;
      uploadToFireStore();
    });
  }

  uploadToFireStore() {
    List<String> tagsList = tags != null ? tags.split(',').toList() : [];
    tagsList.add(titleOfNote);
    firestore.collection('notes').add({
      'noteUrl': downloadUrl,
      'lat': currentLocation.latitude,
      'long': currentLocation.longitude,
      'uid': uid,
      'isApproved': false,
      'likes': 0,
      'fav': 0,
      'title': titleOfNote,
      'tag': FieldValue.arrayUnion(tagsList),
      'address': addressName,
      'pic': imageUrl,
      'watchedPeople': 0,
      'token': messagingToken,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch
    }).then((value) {
      setState(() {
        titleOfNote = null;
        tagsList = null;
      });
      print('\n\n\n\n\nWow\n\n\n\n');
    });
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  void _logOut() {
    FirebaseAuth.instance.signOut();
    logOutUid();
  }

  double dia;

  logOutUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', null);
    prefs.setString('image', null);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }

  List<DocumentSnapshot> docs = [];

  getDocS(distance) {
    docs.clear();
    firestore
        .collection('notes')
        .where('isApproved', isEqualTo: true)
        .getDocuments()
        .then((value) {
      docs = value.documents;
      docs.forEach((element) {
        final location = LatLng(element.data['lat'], element.data['long']);

        Geolocator()
            .distanceBetween(
                CurrentLatLng.latitude == null ? 123 : CurrentLatLng.latitude,
                CurrentLatLng.longitude,
                location.latitude,
                location.longitude)
            .then((calculatedDistance) {
          if (calculatedDistance <= distance) {
            addMar(location: location, doc: element);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavBar(context, 0),
      key: _scaffoldKey,
      drawer: MyDrawer(
        logOut: () {
          _logOut();
        },
      ),
      body: Stack(
        children: [
          isSearch
              ? StreamBuilder<QuerySnapshot>(
                  stream: qurey,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data.documents;
                      data.forEach((element) {
                        final location = LatLng(
                            element.data['lat'] == null
                                ? 1233
                                : element.data['lat'],
                            element.data['long']);

                        Geolocator()
                            .distanceBetween(
                                CurrentLatLng.latitude == null
                                    ? 124
                                    : CurrentLatLng.latitude,
                                CurrentLatLng.longitude,
                                location.latitude,
                                location.longitude)
                            .then((calculatedDistance) {
                          if (calculatedDistance <= diameter) {
                            addMar(location: location, doc: element);
                          }
                        });
                      });
                    }

                    return Container();
                  })
              : StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('notes')
                      .where('isApproved', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data.documents;
                      data.forEach((element) {
                        final location = LatLng(
                            element.data['lat'] == null
                                ? 1233
                                : element.data['lat'],
                            element.data['long']);

                        Geolocator()
                            .distanceBetween(
                                CurrentLatLng.latitude == null
                                    ? 123
                                    : CurrentLatLng.latitude,
                                CurrentLatLng.longitude,
                                location.latitude,
                                location.longitude)
                            .then((calculatedDistance) {
                          if (calculatedDistance <= diameter) {
                            addMar(location: location, doc: element);
                          }
                        });
                      });
                    }

                    return Container();
                  }),

          Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: GoogleMap(
              onTap: (v) {
                if (audioPlayer != null) {
                  audioPlayer.stop();
                }
                setState(() {
                  isMarkerClicked = false;
                });
              },
              markers: markers,
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              circles: circles,
              myLocationButtonEnabled: true,
            ),
          ),
          isMarkerClicked
              ? Positioned(top: 100, right: 40, child: _message())
              : Container(), // THis is the audio note
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: SizeConfig.screenWidth - 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState.openDrawer();
                              },
                              child: Icon(Icons.sort),
                            ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {},
                        child: isSearch
                            ? TextFormField(
                                onFieldSubmitted: (i) {
                                  print('i am called in search buttons');
                                  markers.clear();
                                  setState(() {
                                    qurey  =
//                                    = isTitleSearchCondition
//                                        ? firestore
//                                            .collection('notes')
//                                            .where('isApproved',
//                                                isEqualTo: true)
//                                            .where('title',
//                                                isEqualTo:
//                                                    searchController.text)
//                                            .snapshots()
//                                        :
                                    firestore
                                            .collection('notes')
                                            .where('isApproved',
                                                isEqualTo: true)
                                            .where('tag',
                                                arrayContains:
                                                    searchController.text)
                                            .snapshots();
                                  });
                                },
                                textInputAction: TextInputAction.search,
                                controller: searchController,
                                decoration: InputDecoration(
                                    hintText: 'type here...',
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none),
                              )
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    isSearch = true;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search),
                                    Text('Search here'),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          if (isSearch) {
                            setState(() {
                              isSearch = false;
                            });
                            searchController.clear();
                          }
                        },
                        child: isSearch
                            ? Icon(
                                Icons.clear,
                                color: Colors.blue,
                              )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25.0))),
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => StatefulBuilder(
                                  builder: (context, state) => Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
//              width: SizeConfig.screenWidth,
                                    height: SizeConfig.blockSizeVertical * 65,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                        color: Colors.white),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Enter diameter to view nearby posts in your circle',textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Text('Diameter'),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Container(
                                                          width: 80,
                                                          height: 50,
                                                          child: Form(
                                                            key: formKey,
                                                            child:
                                                                TextFormField(
                                                              validator:
                                                                  (input) {
                                                                if (int.parse(
                                                                            input) <=
                                                                        0 ||
                                                                    int.parse(
                                                                            input) ==
                                                                        -1) {
                                                                  return '1 - 50';
                                                                }
                                                                if (int.parse(
                                                                        input) >
                                                                    50) {
                                                                  return 'Please enter between 1-50';
                                                                }
                                                                return null;
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              onSaved: (input) {
                                                                dia = double.parse(
                                                                        input) *
                                                                    1000;
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                      hintText:
                                                                          ''),
                                                            ),
                                                          )),
                                                      Text('KM'),
                                                    ],
                                                  ),

                                                  MaterialButton(
                                                    color: Colors.blue,
                                                    onPressed: () {
                                                      if (!formKey.currentState
                                                          .validate()) {
                                                        return;
                                                      }

                                                      formKey.currentState
                                                          .save();

                                                      Navigator.pop(context);
                                                      markers.clear();
                                                      setState(() {
                                                        diameter = dia;
                                                      });
                                                      setState(() {
                                                        updateSend(state);
                                                        circles = Set.from([
                                                          Circle(
                                                            circleId: CircleId(
                                                                currentLocation
                                                                    .toString()),
                                                            center: LatLng(
                                                                currentLocation
                                                                    .latitude,
                                                                currentLocation
                                                                    .longitude),
                                                            radius: diameter,
                                                            fillColor: Colors
                                                                .red
                                                                .withOpacity(
                                                                    0.3),
                                                            strokeColor:
                                                                Colors.white,
                                                            strokeWidth: 2,
                                                          )
                                                        ]);
                                                      });
                                                    },
                                                    child: Text(
                                                      'submit',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),

//                                                Slider(
//                                                  min: 500,
//                                                  max: 1000,
//                                                  value: diameter,
//                                                  onChanged: (e) {
//
//                                                    markers.clear();
//                                                    setState(() {
//
//                                                    });
//                                                    setState(() {
//                                                      diameter = e;
//                                                      updateSend(state);
//                                                      circles = Set.from([
//                                                        Circle(
//                                                          circleId: CircleId(
//                                                              currentLocation
//                                                                  .toString()),
//                                                          center: LatLng(
//                                                              currentLocation
//                                                                  .latitude,
//                                                              currentLocation
//                                                                  .longitude),
//                                                          radius: diameter,
//                                                          fillColor: Colors.red
//                                                              .withOpacity(0.3),
//                                                          strokeColor:
//                                                              Colors.white,
//                                                          strokeWidth: 2,
//                                                        )
//                                                      ]);
//                                                    });
//                                                  },
//                                                ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),

                                              Center(
                                                  child: Text(
                                                'Diameter must be in range of 1 - 50',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                      },
                      child: Image.asset(
                        'assets/images/filter.png',
                        scale: 4,
                      )),
                  InkWell(
                      onTap: () {
                        getUserLocation();
                      },
                      child: Image.asset(
                        'assets/images/location.png',
                        scale: 4,
                      )),
                  InkWell(
                      onTap: () {
                        setState(() {
                          running = true;
                          recording = true;
                        });
                        resetStopWatch();
                        startStopWatch();
                        getUserLocation();
                        _start();
                        _modalBottomSheetMenu();
                      },
                      child: Image.asset(
                        'assets/images/record.png',
                        scale: 4,
                      )),
                ],
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: Card(
                    color: Colors.blue.withOpacity(0.3),
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      height: MediaQuery.of(context).size.width * 0.25,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Please wait your note is uploading',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  static var httpClient = new HttpClient();
  bool isLoading = false;

  _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename.wav');
    await file.writeAsBytes(bytes);
    ShareExtend.share(file.path, "file", subject: "From Bondo App");
  }

//  void _stop() {
//    setState(() {
//      running = false;
//      send = true;
//    });
//  }

  void _send() {
    setState(() {
      recording = false;
      send = false;
    });
  }

  Future<Null> updateSend(StateSetter updateState) async {
    updateState(() {
      recording = false;
      send = false;
    });
  }

  Future<Null> updateStop(StateSetter updateState) async {
    updateState(() {
      running = false;
      send = true;
    });
  }

  TextEditingController titleController = TextEditingController();
  int titleLength = 0;

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, state) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenWidth * 1.8,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      color: Colors.white),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Voice Recording...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 10,
                                  right: SizeConfig.blockSizeHorizontal * 42),
                              child: Text(
                                'Timer',
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
                              )),
                          Container(
                            margin: EdgeInsets.only(
                                left: SizeConfig.blockSizeHorizontal * 1),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                StreamBuilder<int>(
                                  stream: _stopWatchTimer.rawTime,
                                  initialData: 0,
                                  builder: (context, snap) {
                                    final value = snap.data;
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(value)
                                            .split('.');
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            displayTime[0],
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal * 5,
                                ),
                                //!send ?
                                Padding(
                                  padding: const EdgeInsets.only(right: 40),
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        updateStop(state);
                                        _stop();
                                        stopStopWatch();
                                        resetStopWatch();
                                      },
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: red,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )),
                                ),
//                                      : Padding(
//                                    padding:
//                                    const EdgeInsets.only(right: 40),
//                                    child: GestureDetector(
//                                      onTap: () {
//                                        if (titleOfNote == null) {
//                                          Toast.show(
//                                              'Title is Required', context,
//                                              gravity: Toast.BOTTOM);
//                                          return;
//                                        }
//                                        updateSend(state);
//                                        Navigator.pop(context);
//                                        uploadVoiceNote(voiceNote);
//                                        _init();
//                                        resetStopWatch();
//                                        //onPlayAudio();
//                                      },
//                                      child: CircleAvatar(
//                                          radius: 25,
//                                          backgroundColor: green,
//                                          child: Image.asset(
//                                            'assets/images/send.png',
//                                            scale: 5,
//                                          )),
//                                    ),
//                                  ),

                                !send
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: GestureDetector(
                                          onTap: () {
                                            updateStop(state);
                                            stopStopWatch();
                                            _stop();
                                            //onPlayAudio();
                                          },
                                          child: CircleAvatar(
                                              radius: 25,
                                              backgroundColor: green,
                                              child: Icon(
                                                Icons.stop,
                                                color: Colors.white,
                                              )),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 40),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (titleOfNote == null) {
                                              Toast.show(
                                                  'Title is Required', context,
                                                  gravity: Toast.BOTTOM);
                                              return;
                                            }
                                            updateSend(state);
                                            uploadVoiceNote(voiceNote);
                                            resetStopWatch();
                                            //onPlayAudio();
                                          },
                                          child: CircleAvatar(
                                              radius: 25,
                                              backgroundColor: green,
                                              child: Image.asset(
                                                'assets/images/send.png',
                                                scale: 5,
                                              )),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                          ),
                          Divider(),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Title:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                          ),
                          new Container(
                            width: SizeConfig.screenWidth * .9,
                            //  height: 50,
                            decoration: BoxDecoration(),
                            padding:
                                const EdgeInsets.only(left: 0.0, right: 10.0),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom:
//                                  MediaQuery.of(context).viewInsets.bottom
                                      10),
                              child: TextField(
                                controller: titleController,
                                onChanged: (input) {
                                  if (titleController.text.length < 60) {
                                    setState(() {
                                      titleOfNote = input;
                                      titleLength = titleController.text.length;
                                    });
                                  }

                                  print(titleOfNote);
                                },
                                maxLines: 2,
                                maxLength: 30,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10.0),
                                  hintText: "Call to action ",
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                          ),

                          Divider(),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '#Tag:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
//                              SizedBox(
//                                height: SizeConfig.blockSizeVertical * 2,
//                              ),
                          new Container(
                            width: SizeConfig.screenWidth * .9,
                            height: 50,
                            decoration: BoxDecoration(),
                            padding:
                                const EdgeInsets.only(left: 0.0, right: 10.0),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: TextField(
                                onChanged: (input) {
                                  setState(() {
                                    tags = input;
                                  });
                                  print(tags);
                                },
                                maxLines: 1,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10.0),
                                  hintText: "# Tag, Tag",
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )).whenComplete(() {
      print('I AM CLOSED');
      setState(() {
        _send();
      });
    });
  }

  Widget _message() {
    return Container(
      height: SizeConfig.blockSizeVertical * 22,
      width: SizeConfig.blockSizeHorizontal * 80,
//      color: deleteList.contains(index)?red:Colors.white,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        padding: EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54.withOpacity(0.3),
              )
            ]),
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: _upperPart()),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                  child: _play()),
            ),
            SizedBox(
              height: 10,
            ),
            _option(Note),
          ],
        ),
      ),
    );

//      StreamBuilder<DocumentSnapshot>(
//        stream:
//            firestore.collection('notes').document(Note.documentID).snapshots(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) {
//            return Center(
//              child: CircularProgressIndicator(),
//            );
//          }
//
//          final Data = snapshot.data;
//
//          Note = Data;
//
//          return Container(
//            height: SizeConfig.blockSizeVertical * 22,
//            width: SizeConfig.blockSizeHorizontal * 80,
////      color: deleteList.contains(index)?red:Colors.white,
//            child: Container(
//              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//              padding: EdgeInsets.only(top: 12),
//              decoration: BoxDecoration(
//                  color: Colors.white,
//                  borderRadius: BorderRadius.all(
//                    Radius.circular(20),
//                  ),
//                  boxShadow: [
//                    BoxShadow(
//                      color: Colors.black54.withOpacity(0.3),
//                    )
//                  ]),
//              child: Column(
//                children: [
//                  Container(
//                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
//                      child: _upperPart(index)),
//                  Padding(
//                    padding: EdgeInsets.only(top: 5),
//                    child: Container(
//                        margin:
//                            EdgeInsets.symmetric(horizontal: 30, vertical: 0),
//                        child: _play()),
//                  ),
//                  SizedBox(
//                    height: 10,
//                  ),
//                  _option(Note),
//                ],
//              ),
//            ),
//          );
//        });
  }

  sendShare(String note, String title) {
    _downloadFile(note, title);
  }

  Widget _option(DocumentSnapshot doc) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Row(
          children: [
            InkWell(
              onTap: () {
                print('called');
                sendShare(doc.data['noteUrl'], doc.data['title']);
              },
              child: Icon(
                Icons.share,
                color: Colors.grey,
              ),
            )
          ],
        ),
        StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('notes')
                .document(Note.documentID)
                .collection('fav')
                .snapshots(),
            builder: (context, snapshot) {
              bool isFav;

              if (!snapshot.hasData) {
                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (isFav) {
                          print('deleted');
                          firestore
                              .collection('notes')
                              .document(Note.documentID)
                              .collection('fav')
                              .document(MyUid)
                              .delete();

                          firestore
                              .collection('fav')
                              .document(MyUid)
                              .collection('fav')
                              .document(Note.documentID)
                              .delete();
                        } else {
                          print('added');
                          firestore
                              .collection('notes')
                              .document(Note.documentID)
                              .collection('fav')
                              .document(MyUid)
                              .setData({'fav': true});

                          firestore
                              .collection('fav')
                              .document(MyUid)
                              .collection('fav')
                              .document(Note.documentID)
                              .setData({
                            'noteUrl': Note.data['noteUrl'],
                            'lat': currentLocation.latitude,
                            'long': currentLocation.longitude,
                            'uid': uid,
                            'title': Note.data['title'],
                            'address': addressName,
                            'pic': Note.data['pic'],
                            'watchedPeople': 0,
                            'token': messagingToken,
                            'timestamp':
                                DateTime.now().toUtc().millisecondsSinceEpoch
                          });
                        }
                      },
                      child: Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 3), child: Text("0"))
//                StreamBuilder<QuerySnapshot>(
//                  stream: firestore.collection('notes').document(Note.documentID).collection('fav').snapshots(),
//                  builder: (BuildContext context, snapshot){
//
//                    if(!snapshot.hasData){
//                      return Padding(
//                          padding: EdgeInsets.only(left: 3),
//                          child: Text("0"));
//                    }
//                    int FavCount = snapshot.data.documents.length;
//
//                    return Padding(
//                        padding: EdgeInsets.only(left: 3),
//                        child: Text(FavCount.toString()));
//                  },
//                ),
                  ],
                );
              }

              List<DocumentSnapshot> Data = snapshot.data.documents;

              int FavCount = Data.length;

//               bool isFav =  Data.where()

              isFav = snapshot.data.documents
                  .any((element) => element.documentID == MyUid);

              return Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (isFav) {
                        print('deleted');
                        firestore
                            .collection('notes')
                            .document(Note.documentID)
                            .collection('fav')
                            .document(MyUid)
                            .delete();

                        firestore
                            .collection('fav')
                            .document(MyUid)
                            .collection('fav')
                            .document(Note.documentID)
                            .delete();
                      } else {
                        print('added');
                        firestore
                            .collection('notes')
                            .document(Note.documentID)
                            .collection('fav')
                            .document(MyUid)
                            .setData({'fav': true});

                        firestore
                            .collection('fav')
                            .document(MyUid)
                            .collection('fav')
                            .document(Note.documentID)
                            .setData({
                          'noteUrl': Note.data['noteUrl'],
                          'lat': currentLocation.latitude,
                          'long': currentLocation.longitude,
                          'uid': uid,
                          'title': Note.data['title'],
                          'address': addressName,
                          'pic': Note.data['pic'],
                          'watchedPeople': 0,
                          'token': messagingToken,
                          'timestamp':
                              DateTime.now().toUtc().millisecondsSinceEpoch
                        });
                      }
                    },
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Text(FavCount.toString())),
//                StreamBuilder<QuerySnapshot>(
//                  stream: firestore.collection('notes').document(Note.documentID).collection('fav').snapshots(),
//                  builder: (BuildContext context, snapshot){
//
//                    if(!snapshot.hasData){
//                      return Padding(
//                          padding: EdgeInsets.only(left: 3),
//                          child: Text("0"));
//                    }
//                    int FavCount = snapshot.data.documents.length;
//
//                    return Padding(
//                        padding: EdgeInsets.only(left: 3),
//                        child: Text(FavCount.toString()));
//                  },
//                ),

                  // ----------------------
                ],
              );
            }),
        StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('notes')
                .document(Note.documentID)
                .collection('likes')
                .snapshots(),
            builder: (context, snapshot) {
              bool isFav;

              if (!snapshot.hasData) {
                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (isFav) {
                          print('deleted');
                          firestore
                              .collection('notes')
                              .document(Note.documentID)
                              .collection('likes')
                              .document(MyUid)
                              .delete();

                          firestore
                              .collection('fav')
                              .document(MyUid)
                              .collection('likes')
                              .document(Note.documentID)
                              .delete();
                        } else {
                          print('added');
                          firestore
                              .collection('notes')
                              .document(Note.documentID)
                              .collection('likes')
                              .document(MyUid)
                              .setData({'likes': true});

//                            firestore.collection('fav').document(MyUid).collection('fav').document(Note.documentID).setData({
//                              'noteUrl': Note.data['noteUrl'],
//                              'lat': currentLocation.latitude,
//                              'long': currentLocation.longitude,
//                              'uid': uid,
//                              'title': Note.data['title'],
//                              'address': addressName,
//                              'pic': Note.data['pic'],
//                              'watchedPeople': 0,
//                              'token': messagingToken,
//                              'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch
//                            });
                        }
                      },
                      child: Icon(
                        Icons.thumb_up,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 3), child: Text("0"))
//                StreamBuilder<QuerySnapshot>(
//                  stream: firestore.collection('notes').document(Note.documentID).collection('fav').snapshots(),
//                  builder: (BuildContext context, snapshot){
//
//                    if(!snapshot.hasData){
//                      return Padding(
//                          padding: EdgeInsets.only(left: 3),
//                          child: Text("0"));
//                    }
//                    int FavCount = snapshot.data.documents.length;
//
//                    return Padding(
//                        padding: EdgeInsets.only(left: 3),
//                        child: Text(FavCount.toString()));
//                  },
//                ),
                  ],
                );
              }

              List<DocumentSnapshot> Data = snapshot.data.documents;

              int FavCount = Data.length;

//               bool isFav =  Data.where()

              isFav = snapshot.data.documents
                  .any((element) => element.documentID == MyUid);

              return Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (isFav) {
                        print('deleted');
                        firestore
                            .collection('notes')
                            .document(Note.documentID)
                            .collection('likes')
                            .document(MyUid)
                            .delete();
                      } else {
                        print('added');
                        firestore
                            .collection('notes')
                            .document(Note.documentID)
                            .collection('likes')
                            .document(MyUid)
                            .setData({'fav': true});
                      }
                    },
                    child: Icon(
                      Icons.thumb_up,
                      color: isFav ? Colors.blue : Colors.grey,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Text(FavCount.toString()))
//                StreamBuilder<QuerySnapshot>(
//                  stream: firestore.collection('notes').document(Note.documentID).collection('fav').snapshots(),
//                  builder: (BuildContext context, snapshot){
//
//                    if(!snapshot.hasData){
//                      return Padding(
//                          padding: EdgeInsets.only(left: 3),
//                          child: Text("0"));
//                    }
//                    int FavCount = snapshot.data.documents.length;
//
//                    return Padding(
//                        padding: EdgeInsets.only(left: 3),
//                        child: Text(FavCount.toString()));
//                  },
//                ),

                  // ----------------------
                ],
              );
            }),
        GestureDetector(
          onTap: () {
            if (isPlayed == false) {
              onPlayAudio();
              setState(() {
                isPlayed = true;
                playerState = PlayerState.playing;
              });
            } else {
              audioPlayer.pause();
              setState(() {
                isPlayed = false;
                playerState = PlayerState.paused;
              });
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 0, right: 10),
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(
              child: Icon(
                isPlayed ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isPlayed = false;

  Widget _upperPart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        noteImage == null
            ? Image.asset(
                'assets/images/avatar.png',
                scale: 3.5,
              )
            : CircleAvatar(
                backgroundImage: NetworkImage(noteImage),
              ),
        Expanded(
          child: Container(
              margin: EdgeInsets.only(left: 10, top: 0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      Note.data['title'],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )),
        ),
        GestureDetector(
          onTap: () {
            audioPlayer.stop();
            _audioPlayerStateSubscription.cancel();
            _positionSubscription.cancel();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => Reply(
                          doc: Note,
                        ))).then((value) {
              initState();
            });
          },
          child: new Container(
            width: SizeConfig.blockSizeHorizontal * 20,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 0.5, color: Colors.grey),
            ),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.reply,
                  color: Colors.blue,
                  size: 20,
                ),
                Text('Reply')
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _play() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(right: 10), child: Text(currentTime)),
          Container(
              width: SizeConfig.blockSizeHorizontal * 40,
              child: duration != null
                  ? Slider(
                      value: position?.inMilliseconds?.toDouble() ?? 0.0,
                      onChanged: (double value) {
                        return audioPlayer.seek((value / 1000).roundToDouble());
                      },
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble())
                  : Slider(value: 0, onChanged: null)),
        ],
      ),
    );
  }

  void onPlayAudio() async {
    int NoOfPlay = int.parse(Note.data['watchedPeople'].toString());

    NoOfPlay = NoOfPlay + 1;
    print('\n\n\n\n\n$NoOfPlay\n\n\n\n\n');
    firestore
        .collection('notes')
        .document(Note.documentID)
        .setData({'watchedPeople': NoOfPlay}, merge: true).then((value) {
      print('Success');
    }).catchError((e) {
      print('error');
    });
    await audioPlayer.play(
      Note.data['noteUrl'],
    );
  }

  void startStopWatch() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
  }

  void stopStopWatch() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
  }

  void resetStopWatch() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
  }

  void onLiked() {
    print(MyUid);

    firestore
        .collection('notes')
        .document(Note.documentID)
        .collection('likes')
        .document(MyUid)
        .setData({'fav': true});
  }

  void onFav() {
    print(MyUid);

    firestore
        .collection('notes')
        .document(Note.documentID)
        .collection('fav')
        .document(MyUid)
        .setData({'fav': true});

    firestore
        .collection('fav')
        .document(MyUid)
        .collection('fav')
        .document(Note.documentID)
        .setData({
      'noteUrl': Note.data['noteUrl'],
      'lat': currentLocation.latitude,
      'long': currentLocation.longitude,
      'uid': uid,
      'title': Note.data['title'],
      'address': addressName,
      'pic': Note.data['pic'],
      'watchedPeople': 0,
      'token': messagingToken,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch
    });
  }

  Duration duration;
  Duration position;
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Search Field'),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            setState(() {
              isTitleSearchCondition = true;
            });
            Navigator.pop(context);
          },
          child: Text('Title'),
          color: isTitleSearchCondition ? Colors.orange : Colors.white,
        ),
        MaterialButton(
          onPressed: () {
            setState(() {
              isTitleSearchCondition = false;
            });
            Navigator.pop(context);
          },
          child: Text('Tag'),
          color: isTitleSearchCondition ? Colors.white : Colors.orange,
        ),
      ],
    );
  }
}
