import 'dart:async';
import 'dart:io';
import 'package:bondo/main.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:bondo/config/size_config.dart';
import 'package:bondo/screens/reply.dart';
import 'package:bondo/utils/color.dart';
import 'package:bondo/utils/routes.dart';
import 'package:bondo/widgets/bottomNavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';
class VoiceMessage extends StatefulWidget {
  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}
Firestore firestore = Firestore.instance;
//enum t_MEDIA {
//  FILE,
//  BUFFER,
//  ASSET,
//  STREAM,
//  REMOTE_EXAMPLE_FILE,
//}

enum PlayerState { stopped, playing, paused }
class _VoiceMessageState extends State<VoiceMessage> {
/*
  bool _isRecording = false;
  List<String> _path = [null, null, null, null, null, null, null];
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  StreamSubscription _playbackStateSubscription;

  FlutterSoundPlayer playerModule;
  FlutterSoundRecorder recorderModule;

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  t_MEDIA _media = t_MEDIA.FILE;
  t_CODEC _codec = t_CODEC.CODEC_AAC;

  bool _encoderSupported = true; // Optimist
  bool _decoderSupported = true; // Optimist

  // Whether the user wants to use the audio player features
  bool _isAudioPlayer = false;
  bool _duckOthers = false;

  double _duration = null;

  Future<void> _initializeExample(FlutterSoundPlayer module) async {
    playerModule = module;

    await module.initialize();
    await playerModule.setSubscriptionDuration(0.01);
    await recorderModule.setSubscriptionDuration(0.01);
    initializeDateFormatting();
    setCodec(_codec);
    setDuck();
  }

  Future<void> init() async {
    playerModule = await FlutterSoundPlayer().initialize();
    recorderModule = await FlutterSoundRecorder().initialize();
    await _initializeExample(playerModule);

    await recorderModule.setDbPeakLevelUpdate(0.8);
    await recorderModule.setDbLevelEnabled(true);
    await recorderModule.setDbLevelEnabled(true);
    if (Platform.isAndroid) {
      copyAssets();
    }
  }

  Future<void>copyAssets() async {
    Uint8List dataBuffer = (await rootBundle.load("assets/canardo.png" )).buffer.asUint8List( );
    String path = await playerModule.getResourcePath() + "/assets";
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
    await File(path + '/canardo.png').writeAsBytes(dataBuffer);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
    if (_dbPeakSubscription != null) {
      _dbPeakSubscription.cancel();
      _dbPeakSubscription = null;
    }
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }

    if (_playbackStateSubscription != null) {
      _playbackStateSubscription.cancel();
      _playbackStateSubscription = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    cancelRecorderSubscriptions();
    releaseFlauto();
  }

  Future<void> setDuck() async {
    if (_duckOthers) {
      if (Platform.isIOS)
        await playerModule.iosSetCategory(t_IOS_SESSION_CATEGORY.PLAY_AND_RECORD, t_IOS_SESSION_MODE.DEFAULT, IOS_DUCK_OTHERS | IOS_DEFAULT_TO_SPEAKER);
      else if (Platform.isAndroid) await playerModule.androidAudioFocusRequest(ANDROID_AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK);
    } else {
      if (Platform.isIOS)
        await playerModule.iosSetCategory(t_IOS_SESSION_CATEGORY.PLAY_AND_RECORD, t_IOS_SESSION_MODE.DEFAULT, IOS_DEFAULT_TO_SPEAKER);
      else if (Platform.isAndroid) await playerModule.androidAudioFocusRequest(ANDROID_AUDIOFOCUS_GAIN);
    }
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule.release();
      await recorderModule.release();
    } catch (e) {
      print('Released unsuccessful');
      print(e);
    }
  }

  static const List<String> paths = [
    'flutter_sound_example.aac', // DEFAULT
    'flutter_sound_example.aac', // CODEC_AAC
    'flutter_sound_example.opus', // CODEC_OPUS
    'flutter_sound_example.caf', // CODEC_CAF_OPUS
    'flutter_sound_example.mp3', // CODEC_MP3
    'flutter_sound_example.ogg', // CODEC_VORBIS
    'flutter_sound_example.pcm', // CODEC_PCM
  ];

  void startRecorder() async {
    try {
      // String path = await flutterSoundModule.startRecorder
      // (
      //   paths[_codec.index],
      //   codec: _codec,
      //   sampleRate: 16000,
      //   bitRate: 16000,
      //   numChannels: 1,
      //   androidAudioSource: AndroidAudioSource.MIC,
      // );
      Directory tempDir = await getTemporaryDirectory();

      String path = await recorderModule.startRecorder(
        uri: '${tempDir.path}/${recorderModule.slotNo}-${paths[_codec.index]}',
        codec: _codec,
      );
      print('startRecorder: $path');

      _recorderSubscription = recorderModule.onRecorderStateChanged.listen((e) {
        if (e != null && e.currentPosition != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt(), isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

          this.setState(() {
            this._recorderTxt = txt.substring(0, 8);
          });
        }
      });
      _dbPeakSubscription = recorderModule.onRecorderDbPeakChanged.listen((value) {
        print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
        this._path[_codec.index] = path;
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        stopRecorder();
        this._isRecording = false;
        if (_recorderSubscription != null) {
          _recorderSubscription.cancel();
          _recorderSubscription = null;
        }
        if (_dbPeakSubscription != null) {
          _dbPeakSubscription.cancel();
          _dbPeakSubscription = null;
        }
      });
    }
  }

  Future<void> getDuration() async {
    switch (_media) {
      case t_MEDIA.FILE:
      case t_MEDIA.BUFFER:
        int d = await flutterSoundHelper.duration(this._path[_codec.index]);
        _duration = d != null ? d / 1000.0 : null;
        break;
      case t_MEDIA.ASSET:
        _duration = null;
        break;
      case t_MEDIA.REMOTE_EXAMPLE_FILE:
        _duration = null;
        break;
    }
    setState(() {});
  }

  void stopRecorder() async {
    try {
      String result = await recorderModule.stopRecorder();
      print('stopRecorder: $result');
      cancelRecorderSubscriptions();

      getDuration();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    this.setState(() {
      this._isRecording = false;
    });
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
  Future<Uint8List> makeBuffer(String path) async {
    try {
      if (!await fileExists(path)) return null;
      File file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      print('The file is ${contents.length} bytes long.');
      return contents;
    } catch (e) {
      print(e);
      return null;
    }
  }

  List<String> assetSample = [
    'assets/samples/sample.aac',
    'assets/samples/sample.aac',
    'assets/samples/sample.opus',
    'assets/samples/sample.caf',
    'assets/samples/sample.mp3',
    'assets/samples/sample.ogg',
    'assets/samples/sample.pcm',
  ];

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onPlayerStateChanged.listen((e) {
      if (e != null) {
        maxDuration = e.duration;
        if (maxDuration <= 0) maxDuration = 0.0;

        sliderCurrentPosition = min(e.currentPosition, maxDuration);
        if (sliderCurrentPosition < 0.0) {
          sliderCurrentPosition = 0.0;
        }

        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt(), isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        this.setState(() {
          //this._isPlaying = true;
          this._playerTxt = txt.substring(0, 8);
        });
      }
    });
  }

  Future<void> startPlayer() async {
    try {
      String path;
      Uint8List dataBuffer;
      String audioFilePath;
      if (_media == t_MEDIA.ASSET) {
        dataBuffer = (await rootBundle.load(assetSample[_codec.index])).buffer.asUint8List();
      } else if (_media == t_MEDIA.FILE) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[_codec.index])) audioFilePath = this._path[_codec.index];
      } else if (_media == t_MEDIA.BUFFER) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[_codec.index])) {
          dataBuffer = await makeBuffer(this._path[_codec.index]);
          if (dataBuffer == null) {
            throw Exception('Unable to create the buffer');
          }
        }
      } else if (_media == t_MEDIA.REMOTE_EXAMPLE_FILE) {
        // We have to play an example audio file loaded via a URL
        audioFilePath = exampleAudioFilePath;
      }

      // Check whether the user wants to use the audio player features
      if (_isAudioPlayer) {
        String albumArtUrl;
        String albumArtAsset;
        String albumArtFile;
        if (_media == t_MEDIA.REMOTE_EXAMPLE_FILE)
          albumArtUrl = albumArtPath;
        else {

          if (true) {
            albumArtFile = await playerModule.getResourcePath() + "/assets/canardo.png";
            print(albumArtFile);
          } else {

            if (Platform.isIOS) {
              albumArtAsset = 'AppIcon';
            } else if (Platform.isAndroid) {
              albumArtAsset = 'AppIcon.png';
            }
          }
        }

        final track = Track(
          trackPath: audioFilePath,
          dataBuffer: dataBuffer,
          codec: _codec,
          trackTitle: "This is a record",
          trackAuthor: "from flutter_sound",
          albumArtUrl: albumArtUrl,
          albumArtAsset: albumArtAsset,
          albumArtFile: albumArtFile,
        );

        TrackPlayer f = playerModule as TrackPlayer;
        path = await f.startPlayerFromTrack(
            track,
            */
/*canSkipForward:true, canSkipBackward:true,*//*

            whenFinished: () {
              print('I hope you enjoyed listening to this song');
              setState(() {});
            },
            onSkipBackward: () {
              print('Skip backward');
              stopPlayer();
              startPlayer();
            },
            onSkipForward: () {
              print('Skip forward');
              stopPlayer();
              startPlayer();
            },
            onPaused: (bool b) {
              if (b)
                playerModule.pausePlayer();
              else
                playerModule.resumePlayer();
            }
        );
      } else {
        if (audioFilePath != null) {
          path = await playerModule.startPlayer(audioFilePath, codec: _codec, whenFinished: () {
            print('Play finished');
            setState(() {});
          });
        } else if (dataBuffer != null) {
          path = await playerModule.startPlayerFromBuffer(dataBuffer, codec: _codec, whenFinished: () {
            print('Play finished');
            setState(() {});
          });
        }

        if (path == null) {
          print('Error starting player');
          return;
        }
      }
      _addListeners();

      print('startPlayer: $path');
      // await flutterSoundModule.setVolume(1.0);
    } catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  Future<void> stopPlayer() async {
    try {
      String result = await playerModule.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } catch (err) {
      print('error: $err');
    }


    this.setState(() {
      //this._isPlaying = false;
    });
  }

  void pauseResumePlayer() {
    if (playerModule.isPlaying) {
      playerModule.pausePlayer();
    } else {
      playerModule.resumePlayer();
    }
  }

  void pauseResumeRecorder() {
    if (recorderModule.isPaused) {
      {
        recorderModule.resumeRecorder();
      }
    } else {
      recorderModule.pauseRecorder();
    }
  }

  void seekToPlayer(int milliSecs) async {
    String result = await playerModule.seekToPlayer(milliSecs);
    print('seekToPlayer: $result');
  }

  Widget makeDropdowns(BuildContext context) {
    final mediaDropdown = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text('Media:'),
        ),
        DropdownButton<t_MEDIA>(
          value: _media,
          onChanged: (newMedia) {
            if (newMedia == t_MEDIA.REMOTE_EXAMPLE_FILE) _codec = t_CODEC.CODEC_MP3; // Actually this is the only example we use in this example
            _media = newMedia;
            getDuration();
            setState(() {});
          },
          items: <DropdownMenuItem<t_MEDIA>>[
            DropdownMenuItem<t_MEDIA>(
              value: t_MEDIA.FILE,
              child: Text('File'),
            ),
            DropdownMenuItem<t_MEDIA>(
              value: t_MEDIA.BUFFER,
              child: Text('Buffer'),
            ),
            DropdownMenuItem<t_MEDIA>(
              value: t_MEDIA.ASSET,
              child: Text('Asset'),
            ),
            DropdownMenuItem<t_MEDIA>(
              value: t_MEDIA.REMOTE_EXAMPLE_FILE,
              child: Text('Remote Example File'),
            ),
          ],
        ),
      ],
    );

    final codecDropdown = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text('Codec:'),
        ),
        DropdownButton<t_CODEC>(
          value: _codec,
          onChanged: (newCodec) {
            setCodec(newCodec);
            _codec = newCodec;
            getDuration();
            setState(() {});
          },
          items: <DropdownMenuItem<t_CODEC>>[
            DropdownMenuItem<t_CODEC>(
              value: t_CODEC.CODEC_AAC,
              child: Text('AAC'),
            ),
            DropdownMenuItem<t_CODEC>(
              value: t_CODEC.CODEC_OPUS,
              child: Text('OGG/Opus'),
            ),
            DropdownMenuItem<t_CODEC>(
              value: t_CODEC.CODEC_CAF_OPUS,
              child: Text('CAF/Opus'),
            ),
            DropdownMenuItem<t_CODEC>(
              value: t_CODEC.CODEC_MP3,
              child: Text('MP3'),
            ),
            DropdownMenuItem<t_CODEC>(
              value: t_CODEC.CODEC_VORBIS,
              child: Text('OGG/Vorbis'),
            ),
            DropdownMenuItem<t_CODEC>(
              value: t_CODEC.CODEC_PCM,
              child: Text('PCM'),
            ),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: mediaDropdown,
          ),
          codecDropdown,
        ],
      ),
    );
  }

  void Function() onPauseResumePlayerPressed() {
    if (playerModule == null)
      return null;
    if (playerModule.isPaused || playerModule.isPlaying) {
      return pauseResumePlayer;
    }
    return null;
  }

  void Function() onPauseResumeRecorderPressed() {
    if (recorderModule == null)
      return null;
    if (recorderModule.isPaused || recorderModule.isRecording) {
      return pauseResumeRecorder;
    }
    return null;
  }

  void Function() onStopPlayerPressed() {
    if (playerModule == null)
      return null;
    return (playerModule.isPlaying || playerModule.isPaused) ? stopPlayer : null;
  }

  void Function() onStartPlayerPressed() {
    if (playerModule == null)
      return null;
    if (_media == t_MEDIA.FILE || _media == t_MEDIA.BUFFER) // A file must be already recorded to play it
        {
      if (_path[_codec.index] == null) return null;
    }
    if (_media == t_MEDIA.REMOTE_EXAMPLE_FILE && _codec != t_CODEC.CODEC_MP3) // in this example we use just a remote mp3 file
      return null;

    // Disable the button if the selected codec is not supported
    if (!_decoderSupported) return null;
    return (playerModule.isStopped) ? startPlayer : null;
  }

  void Function()  startStopRecorder() {
    if (recorderModule.isRecording || recorderModule.isPaused)
      stopRecorder();
    else
      startRecorder();
  }

  void Function() onStartRecorderPressed() {
    //if (_media == t_MEDIA.ASSET || _media == t_MEDIA.BUFFER || _media == t_MEDIA.REMOTE_EXAMPLE_FILE) return null;
    // Disable the button if the selected codec is not supported
    if (recorderModule == null || !_encoderSupported) return null;
    return startStopRecorder;
  }


  AssetImage recorderAssetImage() {
    if (onStartRecorderPressed() == null) return AssetImage('res/icons/ic_mic_disabled.png');
    return (recorderModule.isStopped)? AssetImage('res/icons/ic_mic.png') : AssetImage('res/icons/ic_stop.png');
  }

  void setCodec(t_CODEC codec) async {
    _encoderSupported = await recorderModule.isEncoderSupported(codec);
    _decoderSupported = await playerModule.isDecoderSupported(codec);

    setState(() {
      _codec = codec;
    });
  }

  void Function(bool) audioPlayerSwitchChanged() {
    if (playerModule == null)
      return null;

    if ( (!playerModule.isStopped) || (recorderModule.isStopped) )
      return null;
    return ((newVal) async {
      try {
        if (playerModule != null) await playerModule.release();

        _isAudioPlayer = newVal;
        if (!newVal) {
          _initializeExample(FlutterSoundPlayer());
        } else {
          _initializeExample(TrackPlayer());
        }
        setState(() {});
      } catch (err) {
        print(err);
      }
    });
  }

  void Function(bool) duckOthersSwitchChanged() {
    return ((newVal) async {
      _duckOthers = newVal;

      try {
        setDuck();
        setState(() {});
      } catch (err) {
        print(err);
      }
    });
  }
*/
//  String description='My opinion about Heliopolis streets renovation',location='Newyork,USA',distance='2.4';
//  String duration='00:00',rename;
//  int timeplays=223,love=21,likes=124;
//  bool delete=false;
//  List<int> deleteList= new List();

  int  distance = 12;
  String currentDuration = '00:00';
  String totalDuration = '00:00';
  AudioPlayer audioplayer = AudioPlayer();
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
  double playPosition=0;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  void onComplete() {
    setState(() {
      playerState = PlayerState.stopped;
    });
  }


  void initAudioPlayer() {
    audioplayer = AudioPlayer();
    _positionSubscription = audioplayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioplayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioplayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }else if (s == AudioPlayerState.COMPLETED) {
            onComplete();

          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = Duration(seconds: 0);
            position = Duration(seconds: 0);
          });
        });
  }



  List<DocumentSnapshot> users = [];

  bool isLoading = true;

  @override
  void initState() {
    firestore.collection('users').getDocuments().then((value){
      users = value.documents;
      setState(() {
        isLoading = false;
      });
    });

    initAudioPlayer();
    audioplayer.onAudioPositionChanged.listen((Duration duration) {
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
    audioplayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: bottomNavBar(context, 1),

        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Voice Message',style: TextStyle(color: Colors.black,fontSize: 20),),
//          actions: [
//            GestureDetector(
//              child: Icon(Icons.search,color: Colors.black,size: 25,),
//
//            ),
//            SizedBox(
//              width: 10,
//            )
//
//          ],
        ),
        body: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          child: isLoading ? Center(child: CircularProgressIndicator(),) : Column(


            children: [

               Container(
                height: SizeConfig.screenHeight-150,
                child: StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection("notes")
                        .orderBy("timestamp",descending: true).where('isApproved',isEqualTo: true).snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return  Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child:
                            Center(child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                child: Text('No Voice Note Found',style: TextStyle(color: Colors.grey),)
                            ),)
                        );
                      }

                      final Data = snapshot.data.documents;

                      return Data.length == 0 ? Center(child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          child: Text('No Voice Note Found',style: TextStyle(color: Colors.grey),)
                      ),) :ListView.builder(
                          itemCount: Data.length,
                          itemBuilder: (BuildContext context, index) {
                            return _message(Data[index]);
                          });
                    }
                ),
              ),

            ],

          ),

        ));

  }
   _message(DocumentSnapshot doc){

    print(users.length);
   DocumentSnapshot myDoc =  users.firstWhere((element) {
    return element.documentID == doc.data['uid'];
    });

   print(myDoc.data['pic']);

    String img = myDoc.data['pic'];
    //String img = null;
//    firestore.collection('users').document(doc.data['uid']).get().then((value) {
//      setState(() {
//        img =  value.data['pic'];
//      });
//     });

     return GestureDetector(
      onTap: (){

      },

      child: Container(
        margin: EdgeInsets.only(top: 5,bottom: 5),
        width: SizeConfig.screenWidth,
        // color: deleteList.contains(index)?red:Colors.white,
        child: Container(
          width: SizeConfig.screenWidth-30,
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              color:Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54.withOpacity(0.3),
                )
              ]),
          child: Column(
            children: [
              _upperPart(doc,img),
//              Padding(padding: EdgeInsets.only(top: 5),
//                child: _play(doc),
//              ),

              SizedBox(height: 10,),
              _option(doc,img),

              SizedBox(height: 10,),
            ],


          ),

        ),
      ),
    );

  }



  void onLiked(DocumentSnapshot doc) {

    print(MyUid);

    firestore
        .collection('notes')
        .document(doc.documentID).collection('likes').document(MyUid).setData({'fav':true});
  }

  void onFav(DocumentSnapshot Note) {
    print(MyUid);

    firestore
        .collection('notes')
        .document(Note.documentID).collection('fav').document(MyUid).setData({'fav':true});
  }


  Widget _option(DocumentSnapshot doc,String img){
    return  new Row(
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
                      InkWell(
                        onTap: (){

                          if(isFav){
                            print('deleted');
                            firestore
                                .collection('notes')
                                .document(doc.documentID).collection('fav').document(MyUid).delete();

                            firestore.collection('fav').document(MyUid).collection('fav').document(doc.documentID).delete();
                          }else{
                            print('added');
                            firestore
                                .collection('notes')
                                .document(doc.documentID).collection('fav').document(MyUid).setData({'fav':true});

                            firestore.collection('fav').document(MyUid).collection('fav').document(doc.documentID).setData({
                              'noteUrl': doc.data['noteUrl'],
                              'uid': MyUid,
                              'title': doc.data['title'],
                              'address': Mainaddress,
                              'pic': doc.data['pic'],
                              'token': messagingToken,
                              'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch
                            });
                          }


                        },
                        child: Icon(Icons.favorite_border,color: Colors.red,),
                      ),
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
                  InkWell(
                    onTap: (){

                      if(isFav){
                        print('deleted');
                        firestore
                            .collection('notes')
                            .document(doc.documentID).collection('fav').document(MyUid).delete();

                        firestore.collection('fav').document(MyUid).collection('fav').document(doc.documentID).delete();
                      }else{
                        print('added');
                        firestore
                            .collection('notes')
                            .document(doc.documentID).collection('fav').document(MyUid).setData({'fav':true});

                        firestore.collection('fav').document(MyUid).collection('fav').document(doc.documentID).setData({
                          'noteUrl': doc.data['noteUrl'],
                          'uid': MyUid,
                          'title': doc.data['title'],
                          'address': Mainaddress,
                          'pic': doc.data['pic'],
                          'token': messagingToken,
                          'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch
                        });
                      }


                    },
                    child: Icon(isFav ? Icons.favorite : Icons.favorite_border,color: Colors.red,),
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
                      InkWell(
                        onTap: (){

                          if(isFav){
                            print('deleted');
                            firestore
                                .collection('notes')
                                .document(doc.documentID).collection('likes').document(MyUid).delete();

                            firestore.collection('fav').document(MyUid).collection('likes').document(doc.documentID).delete();
                          }else{
                            print('added');
                            firestore
                                .collection('notes')
                                .document(doc.documentID).collection('likes').document(MyUid).setData({'likes':true});

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
                        child: Icon(Icons.thumb_up,color: Colors.grey,),
                      ),
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
                  InkWell(
                    onTap: (){

                      if(isFav){
                        print('deleted');
                        firestore
                            .collection('notes')
                            .document(doc.documentID).collection('likes').document(MyUid).delete();

                      }else{
                        print('added');
                        firestore
                            .collection('notes')
                            .document(doc.documentID).collection('likes').document(MyUid).setData({'fav':true});

                      }


                    },
                    child: Icon( Icons.thumb_up ,color: isFav ?Colors.blue: Colors.grey,),
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
            }
        ),

        GestureDetector(
          onTap: (){
            if(audioplayer != null){
              audioplayer.stop();
              _audioPlayerStateSubscription.cancel();
              _positionSubscription.cancel();
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Reply(doc: doc,img: img,))).then((value) {
                initState();
              });
            }



          },
          child: new Container(
            width: SizeConfig.blockSizeHorizontal*20,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 0.5,color: Colors.grey),

            ),
            child: new Row(
              mainAxisAlignment:MainAxisAlignment.center ,
              children: [
                Icon(Icons.reply,color: Colors.blue,size: 20,),
                Text('Reply')
              ],
            ),
          ),
        ),
      ],

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

  Widget _upperPart(DocumentSnapshot doc,String img){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          width: 10,
        ),

        img == null ? Image.asset('assets/images/avatar.png',scale: 3.5,): CircleAvatar(backgroundImage: NetworkImage(img),),
        Container(
            margin: EdgeInsets.only(left: 5,top: 0),
            width: SizeConfig.screenWidth-110,
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Flexible(child: Text(doc.data['title'] == null ? '' : doc.data['title'])),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on,color: red,size: 15),

                          Text(doc.data['address'] == null ? '' : doc.data['address'],style: TextStyle(fontSize: 11,color: Colors.grey),),
                        ],
                      ),

                      GestureDetector(
                        onTap:() {

                          _modalBottomSheetMenu(doc,img);
                        },
                        child: Container(

                          margin: EdgeInsets.only(bottom: 0,right: 10),
                          width: 40,
                          height: 20,

                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(10)),


                          ),
                          child: Center(child: Icon(Icons.play_arrow,color: Colors.white,size: 20,),),
                        ),

                      )

                    ],
                  ),
                )

              ],
            )),
        SizedBox(
          width: SizeConfig.blockSizeHorizontal*3,
        ),


      ],
    );
  }


  void _modalBottomSheetMenu(DocumentSnapshot doc,String img) {
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
                  backgroundImage: NetworkImage(img),
                ),

                SizedBox(
                  height: 20,
                ),
                _play(doc),

                SizedBox(
                  height: 20,
                ),


                PlayButton( doc,audioplayer),
                MaterialButton(
                  shape: StadiumBorder(),
                  color: Color.fromRGBO(76, 123, 254, 1),
                  onPressed: (){
                    Navigator.pop(context);
                    audioplayer.stop();
                  },child: Text('Close',style: TextStyle(color: Colors.white),),),

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
              stream: audioplayer.onAudioPositionChanged,
              builder: (context, snapshot) {
                return Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(this.currentDuration));
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

                       audioplayer.seek((newRating / 1000).roundToDouble());
                      // audioplayer.seek(seconds);
                    },
                    value: value,
                  );
                },
                initialData: 0.0,
                stream: audioplayer.onAudioPositionChanged,
              )

          ),

          buildVolume(setVolume),


        ],
      ),
    );
  }

//void _modalBottomSheetMenu(DocumentSnapshot doc) {
//  showModalBottomSheet(
//      shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
//      context: context,
//      isScrollControlled: true,
//      builder: (context) => StatefulBuilder(
//        builder: (context, state) => Container(
//          padding: EdgeInsets.symmetric(horizontal: 10),
//          width: SizeConfig.screenWidth,
//          height: SizeConfig.screenWidth * 1,
//          decoration: BoxDecoration(
//              borderRadius: BorderRadius.only(
//                  topLeft: Radius.circular(15),
//                  topRight: Radius.circular(15)),
//              color: Colors.white),
//          child: Column(
//            children: <Widget>[
//
//              SizedBox(
//                height: 20,
//              ),
//              CircleAvatar(
//                backgroundImage: NetworkImage(doc.data['pic']),
//                radius: 40,
//              ),
//
//              SizedBox(
//                height: 20,
//              ),
//              _play(doc),
//
//              SizedBox(
//                height: 20,
//              ),
//
//              GestureDetector(
//                onTap: () {
//                  setState(() {
//                  });
//                  onPlayAudio(doc);
//                },
//                child: CircleAvatar(
//                  backgroundColor: Colors.blue,
//                  radius: 20,
//                  child: Center(
//                    child: Icon(
//                      Icons.play_arrow,
//                      color: Colors.white,
//                      size: 20,
//                    ),
//                  ),
//                ),
//              ),
//
//
//            ],
//          ),
//        ),
//      ));
//}
//
//
//Widget _play(DocumentSnapshot doc) {
//
//  bool isMute=false;
//
//  return Container(
//    margin: EdgeInsets.only(top: 20),
//    width: SizeConfig.screenWidth - 50,
//    height: 40,
//    decoration: BoxDecoration(
//      color: fieldBackground,
//      borderRadius: BorderRadius.all(Radius.circular(10)),
//    ),
//    child: Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: [
//
//        SizedBox(
//          width: 10,
//        ),
//
//        StreamBuilder(
//            stream: audioPlayer.onAudioPositionChanged,
//            builder: (context, snapshot) {
//              return Padding(
//                  padding: EdgeInsets.only(right: 5),
//                  child: Text(currentDuration));
//            }
//        ),
//        Expanded(
//          child: StreamBuilder(
//            builder: (BuildContext context,
//                snapshot) {
//              double value = position?.inMilliseconds?.toDouble() ?? 0.0;
//              return Slider(
//                activeColor: Colors.indigoAccent,
//                min: 0.0,
//                max: duration?.inMilliseconds?.toDouble() ?? 0.0,
//                onChanged: (newRating) {
//                },
//                value: value,
//              );
//            },
//            initialData: 0.0,
//            stream: audioPlayer.onAudioPositionChanged,
//          ),
//        ),
//
//        buildVolume(setVolume),
//
//      ],
//    ),
//  );
//}
//


  void cancelPlayerSubscriptions() {
    if (audioplayer != null) {
      _audioPlayerStateSubscription.cancel();
      _audioPlayerStateSubscription = null;
    }
  }

  setVolume(bool d){
    audioplayer.mute(d);
  }
  void onPlayAudio(DocumentSnapshot Note) async {
    await audioplayer.play(
      Note['noteUrl'],
    );
  }
  void _delte(){}
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

