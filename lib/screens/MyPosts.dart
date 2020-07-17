import 'dart:async';
import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/main.dart';
import 'package:bondo/screens/reply.dart';
import 'package:bondo/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';

import '../repliedNotes.dart';

Firestore firestore = Firestore.instance;

class Posts extends StatefulWidget {
  bool isApproved;
  String url;

  Posts(this.isApproved, this.url);

  @override
  _PostsState createState() => _PostsState();
}

enum PlayerState { stopped, playing, paused }

class _PostsState extends State<Posts> {
  AudioPlayer audioPlayer = AudioPlayer();
  String durationTime = '00:00';

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

  void onComplete() {
    print('on complete called');
    setState(() {
      duration = Duration(seconds: 0);
      position = Duration(seconds: 0);
      durationTime = "00:00";
      return playerState = PlayerState.stopped;

    });
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
      }else if (s == AudioPlayerState.COMPLETED) {
        onComplete();
        setState(() {
          position = Duration(seconds: 0);
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
  void dispose() {
    audioPlayer.stop();
    _audioPlayerStateSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    initAudioPlayer();
    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        this.durationTime = duration.toString().split('.')[0];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('notes')
                .where('uid', isEqualTo: MyUid.toString())
                .where('isApproved', isEqualTo: widget.isApproved).orderBy("timestamp",descending: true)
                .snapshots(),
            builder: (BuildContext context, snap) {
              if (!snap.hasData) {
                return  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child:
                    Center(child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                        child: Text(widget.isApproved ? 'No Approved post found': 'No Pending post found',style: TextStyle(
                            color: Colors.grey
                        ),)
                    ),)
                );
              }

              final data = snap.data.documents;

              return

               data.length ==0 ? Container(
                   width: MediaQuery.of(context).size.width,
                   height: MediaQuery.of(context).size.height,
                   child:
                   Center(child: Container(
                       padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                       child: Text(widget.isApproved ? 'No Approved post found': 'No Pending post found',style: TextStyle(
                         color: Colors.grey
                       ),)
                   ),)
               ):
                ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, i) {
                    return  _message(data[i]);
                  });
            }),
      ),
    );
  }


  showDeleteDialog(String docId){
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
      return AlertDialog(
        title: Text('Are you Sure?'),
        content: Text('You want to Delete this Note'),
        actions: <Widget>[
          MaterialButton(
            onPressed: (){
              Navigator.pop(context);
            },
            color: Colors.blueAccent,
            child: Text('cancel',style: TextStyle(color: Colors.white),),
          ),
          MaterialButton(
            onPressed: (){
              firestore
                  .collection('notes').document(docId).delete();
              Navigator.pop(context);
            },
            color: Colors.blueAccent,
            child: Text('Delete',style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    });
  }

  Widget _message(DocumentSnapshot doc) {
    return InkWell(
      onLongPress: (){
        showDeleteDialog(doc.documentID);
      },

      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        width: SizeConfig.screenWidth,
        child: Container(
          width: SizeConfig.screenWidth - 30,
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          padding: EdgeInsets.only(top: 10, bottom: 10),
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
              _upperPart(doc),
//              Padding(padding: EdgeInsets.only(top: 5),
//                child: IconButton(icon: Icon(Icons.play_arrow), onPressed: (){
//                  _modalBottomSheetMenu();
//                }),
//              ),

              SizedBox(
                height: 10,
              ),
              widget.isApproved ? _option(doc) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  static var httpClient = new HttpClient();
  _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename.wav');
    await file.writeAsBytes(bytes);
    ShareExtend.share(file.path, "file",subject: "From Bondo App");
  }

  sendShare(String note,String title) {
    _downloadFile(note, title);

  }





  Widget _option(DocumentSnapshot doc) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Row(
          children: [
            InkWell(
              onTap: () => sendShare(doc.data['noteUrl'],doc.data['title']),
              child: Icon(
                Icons.share,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('notes').document(doc.documentID).collection('fav').snapshots(),
            builder: (context, snapshot) {


              bool isFav;

              if(!snapshot.hasData){
                return
                  Row(
                    children: [
                      Icon(Icons.favorite,color: Colors.red,),
                      Padding(
                          padding: EdgeInsets.only(left: 3),
                          child: Text("0"))
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

              isFav = snapshot.data.documents.any((element) => element.documentID == MyUid);


              return Row(
                children: [
                  Icon( Icons.favorite ,color: Colors.red,),
                  Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Text(FavCount.toString())),

                ],
              );
            }
        ),


        StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('notes').document(doc.documentID).collection('likes').snapshots(),
            builder: (context, snapshot) {


              bool isFav;

              if(!snapshot.hasData){
                return
                  Row(
                    children: [
                      Icon(Icons.thumb_up,color: Colors.grey,),
                      Padding(
                          padding: EdgeInsets.only(left: 3),
                          child: Text("0"))
                    ],
                  );
              }

              List<DocumentSnapshot> Data = snapshot.data.documents;

              int FavCount = Data.length;

//               bool isFav =  Data.where()

              isFav = snapshot.data.documents.any((element) => element.documentID == MyUid);


              return Row(
                children: [
                  Icon( Icons.thumb_up ,color:Colors.blue,),
                  Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Text(FavCount.toString()))

                ],
              );
            }
        ),
      ],
    );
  }



  Widget _upperPart(DocumentSnapshot doc) {
    return InkWell(
      onTap: (){


        if(widget.isApproved){
          audioPlayer.stop();
          _audioPlayerStateSubscription.cancel();
          _positionSubscription.cancel();
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Reply(doc: doc,img: Myimage,))).then((value) {
            initState();
          });
        }

      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            child: widget.url == null
                ? Image.asset(
                    'assets/images/avatar.png',
                    scale: 3.5,
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(widget.url),
                  ),
          ),
          Container(
              margin: EdgeInsets.only(left: 5, top: 0),
              width: SizeConfig.screenWidth - 60,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    child: ListTile(
                      title: Text(doc['title'].toString()),
//                    trailing:  GestureDetector(
//                      onTap: () {
//                        widget.isApproved
//                            ? Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (BuildContext context) =>
//                                        ReplliedPost(doc.documentID)))
//                            : null;
//                      },
//                      child: widget.isApproved ? Container(
//                        width: SizeConfig.blockSizeHorizontal * 20,
//                        height: 30,
//                        decoration: BoxDecoration(
//                          borderRadius: BorderRadius.all(Radius.circular(5)),
//                          border: Border.all(width: 0.5, color: Colors.grey),
//                        ),
//                        child: new Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: [Text('Replies')],
//                        ),
//                      ): Container(
//                        width: 2,
//                        height: 2,
//                      ),
//                    ),
                    ),
                  ),


                  Container(
                    height: 40,
                    child: ListTile(
                      title: Row(
                        children: <Widget>[
                          Icon(Icons.location_on, color: red, size: 15),
                          Text(
                            doc['address'].toString(),
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          //onPlayAudio(doc);
                          _modalBottomSheetMenu(doc);
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
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              )),
        ],
      ),
    );
  }

  final _slider = PublishSubject<double>();
  Stream<double> get sliderStream => _slider.stream;
  Widget _play(DocumentSnapshot doc) {

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
                  child: Text(this.durationTime));
            }
          ),
          Container(
              width: SizeConfig.screenWidth - 180,
              child:
              //duration != null ?
              StreamBuilder(
                      builder: (BuildContext context,
                           snapshot) {
                        double value = position?.inMilliseconds?.toDouble() ?? 0.0;
                        return Slider(
                          activeColor: Colors.indigoAccent,
                          min: 0.0,
                          max: duration?.inMilliseconds?.toDouble() ?? 0.0,
                          onChanged: (newRating) {
                            return audioPlayer.seek((newRating / 1000).roundToDouble());
                          },
                          value: value,
                        );
                      },
                      initialData: 0.0,
                      stream: audioPlayer.onAudioPositionChanged,
                    )

          ),

            buildVolume(setVolume),




        ],
      ),
    );
  }

  setVolume(bool d){
    audioPlayer.mute(d);
  }

  void onPlayAudio(DocumentSnapshot doc) async {
    await audioPlayer.play(
      doc['noteUrl'],
    );
  }

  void _modalBottomSheetMenu(DocumentSnapshot doc) {
    showModalBottomSheet(
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
                      backgroundImage: NetworkImage(widget.url),
                    ),

                    SizedBox(
                      height: 20,
                    ),
                    _play(doc),

                    SizedBox(
                      height: 20,
                    ),



                  PlayButton(doc, audioPlayer),
                    MaterialButton(
                      shape: StadiumBorder(),
                      color: Color.fromRGBO(76, 123, 254, 1),
                      onPressed: (){
                        Navigator.pop(context);
                        audioPlayer.stop();
                      },child: Text('Close',style: TextStyle(color: Colors.white),),),


                  ],
                ),
              ),
            ));
  }
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
    return           GestureDetector(
      onTap: () {
        setState(() {
          isMuted = !isMuted;
        });

        widget.setVolume(isMuted);

      },
      child: Icon(
        isMuted? Icons.volume_mute :Icons.volume_down,
        color: Colors.blue,
        size: 25,
      ),
    );
  }
}


class PlayButton extends StatefulWidget {
  DocumentSnapshot doc;
  AudioPlayer audioPlayer;
  PlayButton(this.doc,this.audioPlayer);

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {

  bool isPause = false;


  @override
  void initState() {
    widget.audioPlayer.onPlayerStateChanged.listen((event) {
      if(event == AudioPlayerState.COMPLETED){
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
        isPause==false ? widget.audioPlayer.pause() :  widget.audioPlayer.play( widget.doc.data['noteUrl'],);
      },
      child: CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 30,
        child: Center(
          child: Icon(
            isPause  ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}


