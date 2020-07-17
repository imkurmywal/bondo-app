import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:bondo/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file/local.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bondo/utils/routes.dart';
import 'package:bondo/config/size_config.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:path/path.dart' as Path;
import 'package:bondo/main.dart';
import 'package:toast/toast.dart';

class FcmReply extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  String pic, title, address, noteUrl, uid, token, docId;
  FcmReply(
      {localFileSystem,
      this.uid,
      this.token,
      this.docId,
      this.address,
      this.title,
      this.noteUrl,
      this.pic})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _FcmReplyState createState() => _FcmReplyState();
}

Firestore firestore = Firestore.instance;

enum PlayerState { stopped, playing, paused }

class _FcmReplyState extends State<FcmReply> {
  TextEditingController titleController = TextEditingController();

  String image = null;

  String name = '';

  getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    image = prefs.getString('image');
    name = prefs.getString('name');
    print('\n\n\n$image\n$name\n\n');
  }

  String distance = '2.4';

  String durationTime = '00:00';
  int timeplays = 223, love = 21, likes = 124;

  Duration duration;
  Duration position;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  double playPosition = 0;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  AudioPlayer audioPlayer = AudioPlayer();

  void onComplete() {
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration(seconds: 0);
    });
  }

  String currentDuration = '00:00';
  String totalDuration = '00:00';

//  @override
//  void dispose() {
//    print('\n\n\n\nDispose in reply\n\n\n');
//    _audioPlayerStateSubscription.cancel();
//    super.dispose();
//  }

  static var httpClient = new HttpClient();
  _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename.wav');
    await file.writeAsBytes(bytes);
    ShareExtend.share(file.path, "file");
  }

  @override
  void initState() {
    _init();
    getUserImage();
    initAudioPlayer();
    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        this.currentDuration = duration.toString().split('.')[0];
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      setState(() => position = p);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              AppRoutes.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Text(
            'Reply',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        body: Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            margin: EdgeInsets.symmetric(horizontal: 3),
            child: Column(children: [
              SizedBox(
                height: SizeConfig.screenHeight * 0.05,
              ),
              Container(
                height: SizeConfig.blockSizeVertical * 18,
                width: SizeConfig.screenWidth,
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                padding: EdgeInsets.only(top: 20),
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _upperPart(),
//                    Padding(
//                      padding: EdgeInsets.only(top: 5),
//                      child: _play(doc),
//                    ),
                      SizedBox(
                        height: 10,
                      ),
                      //    _option(doc),
                      Divider(),
                      _option()
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 5),
                    child: Text('Replies'),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  // width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('notes')
                          .document(widget.docId)
                          .collection('reply')
                          .snapshots(),
                      builder: (BuildContext context, snap) {
                        if (!snap.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final data = snap.data.documents;

                        return data.length == 0
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: Center(
                                  child: Card(
                                    elevation: 5,
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child:
                                            Text('You don\'t have any post')),
                                  ),
                                ))
                            : ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, i) {
                                  return InkWell(child: _message(data[i]));
                                });
                      }),
                ),
              ),
              Expanded(
                flex: 0,
                child: Card(child: _replayPart()),
              ),
            ])));
  }

  Widget _message(DocumentSnapshot doc) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        //  margin: EdgeInsets.only(bottom: 5),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        width: SizeConfig.screenWidth,
        child: Container(
          width: SizeConfig.screenWidth - 30,
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          padding: EdgeInsets.only(top: 10),
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
              _upperPart(),
//              Padding(padding: EdgeInsets.only(top: 5),
//                child: _play(doc),
//              ),

              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _replayPart() {
    return Container(
      height: 140,
      child: ListView(
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 3,
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: image == null
                    ? AssetImage(
                        'assets/images/person.png',
                      )
                    : NetworkImage(
                        image,
                        scale: 3.5,
                      ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  name == null ? "" : name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 2,
          ),
          Container(
            width: SizeConfig.screenWidth - 50,
            height: SizeConfig.blockSizeVertical * 8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey)),
            child: new Row(
              children: [
                new Container(
                  width: SizeConfig.screenWidth * .65,
                  decoration: BoxDecoration(),
                  padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                  child: TextField(
                    controller: titleController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      hintText:
                          "My opinion about Heliopolis streets renovation",
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        running = true;
                        recording = true;
                      });
                      resetStopWatch();
                      startStopWatch();
                      _start();
                      _modalBottomSheetMenuVoiceMessage();
                    },
                    child: Image.asset(
                      'assets/images/record.png',
                      scale: 4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendShare(String note, String title) {
    _downloadFile(note, title);
  }

  Widget _option() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () => sendShare(widget.noteUrl, widget.title),
          child: new Row(
            children: [
              Icon(
                Icons.share,
                color: Colors.grey,
              )
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('notes')
                .document(widget.docId)
                .collection('fav')
                .orderBy("timestamp", descending: true)
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
                              .document(widget.docId)
                              .collection('fav')
                              .document(MyUid)
                              .delete();

                          firestore
                              .collection('fav')
                              .document(MyUid)
                              .collection('fav')
                              .document(widget.docId)
                              .delete();
                        } else {
                          print('added');
                          firestore
                              .collection('notes')
                              .document(widget.docId)
                              .collection('fav')
                              .document(MyUid)
                              .setData({'fav': true});

                          firestore
                              .collection('fav')
                              .document(MyUid)
                              .collection('fav')
                              .document(widget.docId)
                              .setData({
                            'noteUrl': widget.noteUrl,
                            'uid': MyUid,
                            'docId': widget.docId,
                            'title': widget.title,
                            'address': Mainaddress,
                            'pic': widget.pic,
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
                            .document(widget.docId)
                            .collection('fav')
                            .document(MyUid)
                            .delete();

                        firestore
                            .collection('fav')
                            .document(MyUid)
                            .collection('fav')
                            .document(widget.docId)
                            .delete();
                      } else {
                        print('added');
                        firestore
                            .collection('notes')
                            .document(widget.docId)
                            .collection('fav')
                            .document(MyUid)
                            .setData({'fav': true});

                        firestore
                            .collection('fav')
                            .document(MyUid)
                            .collection('fav')
                            .document(widget.docId)
                            .setData({
                          'noteUrl': widget.noteUrl,
                          'uid': MyUid,
                          'title': widget.title,
                          'address': Mainaddress,
                          'pic': widget.pic,
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
                .document(widget.docId)
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
                              .document(widget.docId)
                              .collection('likes')
                              .document(MyUid)
                              .delete();

                          firestore
                              .collection('fav')
                              .document(MyUid)
                              .collection('likes')
                              .document(widget.docId)
                              .delete();
                        } else {
                          print('added');
                          firestore
                              .collection('notes')
                              .document(widget.docId)
                              .collection('likes')
                              .document(MyUid)
                              .setData({'likes': true});
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
                            .document(widget.docId)
                            .collection('likes')
                            .document(MyUid)
                            .delete();
                      } else {
                        print('added');
                        firestore
                            .collection('notes')
                            .document(widget.docId)
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
      ],
    );
  }

  Widget _upperPart() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 10,
          ),
          widget.pic == null
              ? Image.asset(
                  'assets/images/avatar.png',
                  scale: 3.5,
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(widget.pic),
                ),
          Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 5, top: 0),
                  width: SizeConfig.blockSizeHorizontal * 49,
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                            ),
                            child:
                                Text(widget.title == null ? "" : widget.title),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: new Row(
                          children: [
                            Icon(Icons.location_on, color: red, size: 15),
                            Text(
                              widget.address == null ? "" : widget.address,
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          ),
          Expanded(
            child: Container(),
          ),
          GestureDetector(
            onTap: () => _modalBottomSheetMenu(),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 0, right: 10),
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

//  Widget _upperPart(DocumentSnapshot doc) {
//    return Row(
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: [
//        doc['pic'] == null
//            ? Image.asset(
//          'assets/images/avatar.png',
//          scale: 3.5,
//        )
//            : CircleAvatar(
//          backgroundImage: NetworkImage(doc['pic']),
//        ),
//        Container(
//            margin: EdgeInsets.only(left: 10, top: 0),
//            width: SizeConfig.blockSizeHorizontal * 50,
//            child: Column(
//              children: [
//                Text(doc['title'] == null ? "" : doc['title']),
//                Padding(
//                  padding: EdgeInsets.only(top: 5),
//                  child: new Row(
//                    children: [
//                      Icon(Icons.location_on, color: red, size: 15),
//                      Text(
//                        doc['address'] == null ? "" : doc['address'],
//                        style: TextStyle(fontSize: 11, color: Colors.grey),
//                      )
//                    ],
//                  ),
//                )
//              ],
//            )),
//        SizedBox(
//          width: 20,
//        ),
//        new Row(
//          children: [
//            Image.asset(
//              'assets/images/road.png',
//              scale: 4,
//            ),
//            Text(' ' + distance + 'Miles',
//                style: TextStyle(fontSize: 13, color: Colors.grey))
//          ],
//        ),
//      ],
//    );
//  }

  Widget _play() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: SizeConfig.screenWidth - 50,
      height: 40,
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(
              stream: audioPlayer.onAudioPositionChanged,
              builder: (context, snapshot) {
                return Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(this.currentDuration));
              }),
          Container(
              width: SizeConfig.screenWidth - 180,
              child:
                  //duration != null ?
                  StreamBuilder(
                builder: (BuildContext context, snapshot) {
                  double value = position?.inMilliseconds?.toDouble() ?? 0.0;
                  return Slider(
                    activeColor: Colors.indigoAccent,
                    min: 0.0,
                    max: duration?.inMilliseconds?.toDouble() ?? 0.0,
                    onChanged: (newRating) {
                      audioPlayer.seek((newRating / 1000).roundToDouble());
                    },
                    value: value,
                  );
                },
                initialData: 0.0,
                stream: audioPlayer.onAudioPositionChanged,
              )),
          buildVolume(setVolume),
        ],
      ),
    );
  }

  setVolume(bool d) {
    audioPlayer.mute(d);
  }

//  Widget _play(DocumentSnapshot doc) {
//    return Container(
//      width: SizeConfig.screenWidth - 50,
//      height: 40,
//      decoration: BoxDecoration(
//        color: fieldBackground,
//        borderRadius: BorderRadius.all(Radius.circular(10)),
//      ),
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: [
//          GestureDetector(
//            onTap: () => onPlayAudio(doc),
//            child: Container(
//              margin: EdgeInsets.only(bottom: 0, right: 10),
//              width: 40,
//              height: 20,
//              decoration: BoxDecoration(
//                color: Colors.blue,
//                borderRadius: BorderRadius.all(Radius.circular(10)),
//              ),
//              child: Center(
//                child: Icon(
//                  Icons.play_arrow,
//                  color: Colors.white,
//                  size: 20,
//                ),
//              ),
//            ),
//          ),
//          Padding(
//              padding: EdgeInsets.only(right: 5), child: Text(currentDuration)),
//          Container(
//              width: SizeConfig.screenWidth - 180,
//              child: duration != null
//                  ? Slider(
//                  value: position?.inMilliseconds?.toDouble() ?? 0.0,
//                  onChanged: (double value) {
//                    return audioPlayer.seek((value / 1000).roundToDouble());
//                  },
//                  min: 0.0,
//                  max: duration.inMilliseconds.toDouble())
//                  : Slider(value: 0, onChanged: null)),
//          GestureDetector(
//            onTap: () {
//              print('called');
//              setState(() {
//                isMute = !isMute;
//              });
//              audioPlayer.mute(isMute);
//            },
//            child: Icon(
//             isMute ? Icons.volume_mute :Icons.volume_down,
//              color: Colors.blue,
//              size: 25,
//            ),
//          )
//        ],
//      ),
//    );
//  }

  bool isMute = true;

  void onPlayAudio(DocumentSnapshot Note) async {
    await audioPlayer.play(
      Note['noteUrl'],
    );
  }

  void onPauseAudio() {
    audioPlayer.pause();
  }

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool recording = false;
  Recording _recording = new Recording();
  bool running = false;

  String downloadUrl;

  showSuccessDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your Reply is Uploaded'),
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

  uploadVoiceNote(File file) async {
    Toast.show('Uploading', context, gravity: Toast.BOTTOM);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('voices/${Path.basename(file.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      downloadUrl = fileURL;

      showSuccessDialog();
      uploadToFireStore();
    });
  }

  uploadToFireStore() {
    String titleOfNote = titleController.text;
    print(Mainaddress);
    print(userName);
    firestore
        .collection('notes')
        .document(widget.docId)
        .collection('reply')
        .add({
      'noteUrl': downloadUrl,
      'pic': image,
      'title': titleController.text,
      'address': Mainaddress,
      'userName': userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    }).then((value) {
      titleController.clear();
      setState(() {});
      print('\n\n\n\n\nWow\n\n\n\n');
    });

    firestore.collection('replies').add({
      'pic': image,
      'title': widget.title,
      'token': widget.token,
      'address': Mainaddress,
      'uid': widget.uid,
      'docId': widget.docId
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

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
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

  void resetStopWatch() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
  }

  void startStopWatch() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        // enableDrag: true,
        isDismissible: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
              builder: (context, state) => Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: SizeConfig.screenWidth,
                height: SizeConfig.screenWidth * 1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(widget.pic),
                    ),

                    SizedBox(
                      height: 20,
                    ),
                    _play(),

                    SizedBox(
                      height: 20,
                    ),

                    PlayButton(widget.noteUrl, audioPlayer),

                    MaterialButton(
                      shape: StadiumBorder(),
                      color: Color.fromRGBO(76, 123, 254, 1),
                      onPressed: () {
                        Navigator.pop(context);
                        audioPlayer.stop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

//                GestureDetector(
//                  onTap: () {
//                    setState(() {
//
//                    });
//                    onPlayAudio(doc);
//                  },
//                  child: CircleAvatar(
//                    backgroundColor: Colors.blue,
//                    radius: 30,
//                    child: Center(
//                      child: Icon(
//                        Icons.play_arrow,
//                        color: Colors.white,
//                        size: 20,
//                      ),
//                    ),
//                  ),
//                ),
                  ],
                ),
              ),
            ));
  }

//
//  void _modalBottomSheetMenu(DocumentSnapshot doc) {
//    showModalBottomSheet(
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
//        context: context,
//        isScrollControlled: true,
//        builder: (context) => StatefulBuilder(
//          builder: (context, state) => Container(
//            padding: EdgeInsets.symmetric(horizontal: 10),
//            width: SizeConfig.screenWidth,
//            height: SizeConfig.screenWidth * 1,
//            decoration: BoxDecoration(
//                borderRadius: BorderRadius.only(
//                    topLeft: Radius.circular(15),
//                    topRight: Radius.circular(15)),
//                color: Colors.white),
//            child: Column(
//              children: <Widget>[
//
//                SizedBox(
//                  height: 20,
//                ),
//                CircleAvatar(
//                  radius: 30,
//                  backgroundImage: NetworkImage(doc.data['pic']),
//                ),
//
//                SizedBox(
//                  height: 20,
//                ),
//                _play(doc),
//
//                SizedBox(
//                  height: 20,
//                ),
//
//                GestureDetector(
//                  onTap: () {
//                    setState(() {
//
//                    });
//                    onPlayAudio(doc);
//                  },
//                  child: CircleAvatar(
//                    backgroundColor: Colors.blue,
//                    radius: 30,
//                    child: Center(
//                      child: Icon(
//                        Icons.play_arrow,
//                        color: Colors.white,
//                        size: 20,
//                      ),
//                    ),
//                  ),
//                ),
//
//
//              ],
//            ),
//          ),
//        ));
//  }
//  void _modalBottomSheetMenuPlayer(DocumentSnapshot doc) {
//    showModalBottomSheet(
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
//        context: context,
//        isScrollControlled: true,
//        builder: (context) => StatefulBuilder(
//          builder: (context, state) => Container(
//            padding: EdgeInsets.symmetric(horizontal: 10),
//            width: SizeConfig.screenWidth,
//            height: SizeConfig.screenWidth * 1,
//            decoration: BoxDecoration(
//                borderRadius: BorderRadius.only(
//                    topLeft: Radius.circular(15),
//                    topRight: Radius.circular(15)),
//                color: Colors.white),
//            child: Column(
//              children: <Widget>[
//
//                SizedBox(
//                  height: 20,
//                ),
//                CircleAvatar(
//                  radius: 30,
//                  backgroundImage: NetworkImage(doc.data['pic']),
//                ),
//
//                SizedBox(
//                  height: 20,
//                ),
//                _play(doc),
//
//                SizedBox(
//                  height: 20,
//                ),
//
//                GestureDetector(
//                  onTap: () {
//                    setState(() {
//
//                    });
//                    onPlayAudio(doc);
//                  },
//                  child: CircleAvatar(
//                    backgroundColor: Colors.blue,
//                    radius: 30,
//                    child: Center(
//                      child: Icon(
//                        Icons.play_arrow,
//                        color: Colors.white,
//                        size: 20,
//                      ),
//                    ),
//                  ),
//                ),
//
//
//              ],
//            ),
//          ),
//        ));
//  }

  void _modalBottomSheetMenuVoiceMessage() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
              builder: (context, state) => Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
//              width: SizeConfig.screenWidth,
                height: SizeConfig.blockSizeVertical * 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
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
                                left: SizeConfig.blockSizeHorizontal * 18,
                                bottom: 30),
                            width: SizeConfig.blockSizeHorizontal * 75,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StreamBuilder<int>(
                                  stream: _stopWatchTimer.rawTime,
                                  initialData: 0,
                                  builder: (context, snap) {
                                    final value = snap.data;
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(value);
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            displayTime,
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
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 40),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      updateStop(state);
                                      _stop();
                                      stopStopWatch();
                                      _init();
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
                              !send
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 40),
                                      child: GestureDetector(
                                          onTap: () {
                                            updateStop(state);
                                            stopStopWatch();
                                            _stop();
                                          },
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: red,
                                            child: Icon(
                                              Icons.stop,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          )),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 40),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (titleController.text == null) {
                                            Toast.show(
                                                'Title is Required', context,
                                                gravity: Toast.BOTTOM);
                                            return;
                                          }
                                          updateSend(state);
                                          Navigator.pop(context);
                                          uploadVoiceNote(voiceNote);
                                          _init();
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

  bool send = false;

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

  File voiceNote;

  void stopStopWatch() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
  }

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

  void _send() {}
}

class buildVolume extends StatefulWidget {
  Function setVolume;
  buildVolume(this.setVolume);
  @override
  _buildVolumeState createState() => _buildVolumeState();
}

class _buildVolumeState extends State<buildVolume> {
  bool isMuted = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMuted = !isMuted;
        });

        widget.setVolume(isMuted);
      },
      child: Icon(
        isMuted ? Icons.volume_mute : Icons.volume_down,
        color: Colors.blue,
        size: 25,
      ),
    );
  }
}

class PlayButton extends StatefulWidget {
  AudioPlayer audioPlayer;
  String url;
  PlayButton(this.url, this.audioPlayer);

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool isPause = false;

  @override
  void initState() {
    widget.audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.COMPLETED) {
        setState(() {
          isPause = !isPause;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPause = !isPause;
        });
        isPause == false
            ? widget.audioPlayer.pause()
            : widget.audioPlayer.play(widget.url);
      },
      child: CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 30,
        child: Center(
          child: Icon(
            isPause ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
