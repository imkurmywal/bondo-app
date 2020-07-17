
import 'package:bondo/utils/color.dart';

import 'package:bondo/config/size_config.dart';
import 'package:bondo/utils/dialog.dart';
import 'package:bondo/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VoiceMessage extends StatefulWidget {
  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}
enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
  REMOTE_EXAMPLE_FILE,
}

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
String description='My opinion about Heliopolis streets renovation',location='Newyork,USA',distance='2.4';
String duration='00:00',rename;
int timeplays=223,love=21,likes=124;
bool delete=false;
List<int> deleteList= new List();
@override
  Widget build(BuildContext context) {
   /* final recorderProgressIndicator = _isRecording
        ? LinearProgressIndicator(
      value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      backgroundColor: Colors.red,
    )
        : Container();
    final playerControls = Row(
      children: <Widget>[
        Container(
          width: 56.0,
          height: 56.0,
          child: ClipOval(
            child: FlatButton(
              onPressed: onStartPlayerPressed(),
              padding: EdgeInsets.all(8.0),
              child: Image(
                image: AssetImage(onStartPlayerPressed() != null ? 'res/icons/ic_play.png' : 'res/icons/ic_play_disabled.png'),
              ),
            ),
          ),
        ),
        Container(
          width: 56.0,
          height: 56.0,
          child: ClipOval(
            child: FlatButton(
              onPressed: onPauseResumePlayerPressed(),
              padding: EdgeInsets.all(8.0),
              child: Image(
                width: 36.0,
                height: 36.0,
                image: AssetImage(onPauseResumePlayerPressed() != null ? 'res/icons/ic_pause.png' : 'res/icons/ic_pause_disabled.png'),
              ),
            ),
          ),
        ),
        Container(
          width: 56.0,
          height: 56.0,
          child: ClipOval(
            child: FlatButton(
              onPressed: onStopPlayerPressed(),
              padding: EdgeInsets.all(8.0),
              child: Image(
                width: 28.0,
                height: 28.0,
                image: AssetImage(onStopPlayerPressed() != null ? 'res/icons/ic_stop.png' : 'res/icons/ic_stop_disabled.png'),
              ),
            ),
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    final playerSlider = Container(
        height: 56.0,
        child: Slider(
            value: min(sliderCurrentPosition, maxDuration),
            min: 0.0,
            max: maxDuration,
            onChanged: (double value) async {
              await playerModule.seekToPlayer(value.toInt());
            },
            divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()));

    final dropdowns = makeDropdowns(context);
    final trackSwitch = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text('Track Player:'),
          ),
          Switch(
            value: _isAudioPlayer,
            onChanged: audioPlayerSwitchChanged(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text('Duck Others:'),
          ),
          Switch(
            value: _duckOthers,
            onChanged: duckOthersSwitchChanged(),
          ),
        ],
      ),
    );

    Widget recorderSection = Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
        child: Text(
          this._recorderTxt,
          style: TextStyle(
            fontSize: 35.0,
            color: Colors.black,
          ),
        ),
      ),
      _isRecording ? LinearProgressIndicator(value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100, valueColor: AlwaysStoppedAnimation<Color>(Colors.green), backgroundColor: Colors.red) : Container(),
      Row(
        children: <Widget>[
          Container(
            width: 56.0,
            height: 50.0,
            child: ClipOval(
              child: FlatButton(
                onPressed: onStartRecorderPressed(),
                padding: EdgeInsets.all(8.0),
                child: Image(
                  image: recorderAssetImage(),
                ),
              ),
            ),
          ),
          Container(
            width: 56.0,
            height: 50.0,
            child: ClipOval(
              child: FlatButton(
                onPressed: onPauseResumeRecorderPressed(),
                disabledColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                child: Image(
                  width: 36.0,
                  height: 36.0,
                  image: AssetImage(onPauseResumeRecorderPressed() != null ? 'res/icons/ic_pause.png' : 'res/icons/ic_pause_disabled.png'),
                ),
              ),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    ]);

    Widget playerSection = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
          child: Text(
            this._playerTxt,
            style: TextStyle(
              fontSize: 35.0,
              color: Colors.black,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              width: 56.0,
              height: 50.0,
              child: ClipOval(
                child: FlatButton(
                  onPressed: onStartPlayerPressed(),
                  disabledColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Image(
                    image: AssetImage(onStartPlayerPressed() != null ? 'res/icons/ic_play.png' : 'res/icons/ic_play_disabled.png'),
                  ),
                ),
              ),
            ),
            Container(
              width: 56.0,
              height: 50.0,
              child: ClipOval(
                child: FlatButton(
                  onPressed: onPauseResumePlayerPressed(),
                  disabledColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Image(
                    width: 36.0,
                    height: 36.0,
                    image: AssetImage(onPauseResumePlayerPressed() != null ? 'res/icons/ic_pause.png' : 'res/icons/ic_pause_disabled.png'),
                  ),
                ),
              ),
            ),
            Container(
              width: 56.0,
              height: 50.0,
              child: ClipOval(
                child: FlatButton(
                  onPressed: onStopPlayerPressed(),
                  disabledColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Image(
                    width: 28.0,
                    height: 28.0,
                    image: AssetImage(onStopPlayerPressed() != null ? 'res/icons/ic_stop.png' : 'res/icons/ic_stop_disabled.png'),
                  ),
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        Container(
            height: 30.0,
            child: Slider(
                value: min(sliderCurrentPosition, maxDuration),
                min: 0.0,
                max: maxDuration,
                onChanged: (double value) async {
                  await playerModule.seekToPlayer(value.toInt());
                },
                divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt())),
        Container(
          height: 30.0,
          child: Text(_duration != null ? "Duration: $_duration sec." : ''),
        ),
      ],
    );
*/
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
    title: Text(delete==false?'Voice Message':'Select'+'('+deleteList.length.toString()+')'  ,style: TextStyle(color: Colors.black,fontSize: 20),),
     actions: [
       delete==true?Row(
         children: [
           GestureDetector(
             onTap: (){
               setState(() {
                 for(int i=0;i<6;i++){
                   if(deleteList.contains(i)){}
                   else{
                     deleteList.add(i);
                   }

                 }
               });


             },

           child: Text('Select All',style: TextStyle(color: Colors.blue),),
           ),

           Padding(
             padding: EdgeInsets.only(left: 10),
             child: GestureDetector(
               onTap: (){
                 if(deleteList.length>1 && deleteList.length!=6){
                   showDialog(context: context,child: _deletespecficPopUP());

                 }
                 if(deleteList.length==6){

                   showDialog(context: context,child: _deleteAllPopUP());

                 }
                        else if (deleteList.length==1){
                          showDialog(context: context,child: _deletePopUP());

                 }


               },
               child: Icon(Icons.delete,color: red,),
             ),
           ),

         ],

       ):GestureDetector(
         child: Icon(Icons.search,color: Colors.black,size: 25,),

       ),
       SizedBox(
         width: 10,
       )

     ],
       ),
    body: Container(
    width: SizeConfig.screenWidth,
    height: SizeConfig.screenHeight,
   child: Column(


     children: [

       Container(
         height: SizeConfig.screenHeight-150,
         child: ListView.builder(
             itemCount: 6,
             itemBuilder: (BuildContext context, index) =>_message(index)),
       ),

       ],

   ),

    ));

  }
Widget _message(int index){
    return GestureDetector(
      onTap: (){
        if(deleteList.length==0){
          setState(() {
            delete=false;
          });
        }

        if(delete==true){


          setState(() {
            if(deleteList.contains(index)){
              deleteList.remove(index);

            }
            else{
              deleteList.add(index);

            }
          });

        }
      },

      child: Container(
        margin: EdgeInsets.only(top: 5,bottom: 5),
        width: SizeConfig.screenWidth,
        color: deleteList.contains(index)?red:Colors.white,
        child: Container(
          width: SizeConfig.screenWidth-30,
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              color:Colors.white,
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
              _upperPart(index),
         Padding(padding: EdgeInsets.only(top: 5),
         child: _play(),
         ),

              SizedBox(height: 10,),
           _option(),
            ],


          ),

        ),
      ),
    );

}
Widget _option(){
  return  new Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      new Row(
        children: [
          Icon(Icons.volume_up,color: Colors.blue,)
          ,Text(timeplays.toString())
        ],
      ),
      new Row(
        children: [
          Icon(Icons.share,color: Colors.grey,)
        ],
      ),
      new Row(
        children: [
          Image.asset('assets/images/love.png',scale: 3.5,)
          ,Padding(
              padding: EdgeInsets.only(left: 3),

              child: Text(love.toString()))
        ],
      ),
      new Row(
        children: [
          Image.asset('assets/images/like.png',scale: 3.5,)
          ,Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text(likes.toString()))
        ],
      ),

   GestureDetector(
     onTap: (){
       AppRoutes.push(context,Routes.Reply);

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
Widget _upperPart(int index){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.asset('assets/images/avatar.png',scale: 3.5,),
      Container(
          margin: EdgeInsets.only(left: 5,top: 0),
          width: SizeConfig.blockSizeHorizontal*49,
          child: Column(
            children: [
              Text(description),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: new Row(
                  children: [
                    Icon(Icons.location_on,color: red,size: 15),
                    Text(location,style: TextStyle(fontSize: 11,color: Colors.grey),)
                  ],
                ),
              )

            ],
          )),
      SizedBox(
        width: SizeConfig.blockSizeHorizontal*3,
      ),
      new Row(
        children: [
          Image.asset('assets/images/road.png',scale: 4,)
          ,Text(' '+distance+'Miles',style: TextStyle(fontSize: 11,color: Colors.grey)
          ) ],

      ),
      PopupMenuButton<int>(
        itemBuilder:  (context) => [
          PopupMenuItem(
            value: 1,
            child: Text(
              "Rename",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Text(
              "Delete",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
          PopupMenuItem(
            value: 3,
            child: Text(
              "Report",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
        ],
        child: Icon(Icons.more_vert),
        onSelected: (value){
          if(value==1){
            showDialog(context: context,child: _renamePopUP());


          }
          if(value==2){

              setState(() {
                delete=true;
                deleteList.add(index);



              });
            }
        },
      ),

    ],
  );
}
Widget _play(){
  return Container(
    width: SizeConfig.screenWidth-50,
    height: 40,

    decoration: BoxDecoration(
      color: fieldBackground,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap:_playAudio,
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
        ,
        Padding(
            padding: EdgeInsets.only(right: 5),
            child: Text(duration)),

        Container(
          width: SizeConfig.screenWidth-180,
          child:LinearProgressIndicator(
            backgroundColor: Colors.grey,


          ),
        ),

        GestureDetector(
          onTap: (){


          },
          child: Icon(Icons.volume_down,color: Colors.blue,size: 25,),
        )
      ],
    ),

  );

}
Widget _deleteAllPopUP(){
  return CustomDialog(height: SizeConfig.blockSizeVertical*30,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
            SizedBox(
            height: 10,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(padding: EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: (){
                    AppRoutes.pop(context);

                  },
                  child: Icon(Icons.close),
                ),

              )
            ],
          ),
          Text('Delete',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
          SizedBox(height: SizeConfig.blockSizeVertical*3,),
          Text('Are you sure you want to delete all\n Voice Messages',textAlign: TextAlign.center,),
          SizedBox(height: 20,),
              GestureDetector(
                onTap:_delte,
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
                    child: Text('Delete Now',style: TextStyle(fontSize: 18,color: Colors.white),),
                  ),
                ),
              ),
            ])));}
Widget _deletespecficPopUP(){
  return CustomDialog(height: SizeConfig.blockSizeVertical*30,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(padding: EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: (){
                          AppRoutes.pop(context);

                        },
                        child: Icon(Icons.close),
                      ),

                    )
                  ],
                ),
                Text('Delete',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
                SizedBox(height: SizeConfig.blockSizeVertical*3,),
                Text('Are you sure you want to delete these\n Voice Messages',textAlign: TextAlign.center,),
                SizedBox(height: 20,),
                GestureDetector(
                  onTap:_delte,
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
                      child: Text('Delete Now',style: TextStyle(fontSize: 18,color: Colors.white),),
                    ),
                  ),
                ),
              ])));}
Widget _renamePopUP(){
  return CustomDialog(height: SizeConfig.blockSizeVertical*40,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(padding: EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: (){
                          AppRoutes.pop(context);

                        },
                        child: Icon(Icons.close),
                      ),

                    )
                  ],
                ),

                Text('Rename',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
                SizedBox(height: SizeConfig.blockSizeVertical*3,),
                new Row(
                  mainAxisAlignment:MainAxisAlignment.start ,
                  children: [
                    Text('Title:',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey),)
                  ],
                ),
                SizedBox(height: SizeConfig.blockSizeVertical*2,),
                new Container(
                  width: SizeConfig.screenWidth * .9,
                  decoration: BoxDecoration(),
                  padding:
                  const EdgeInsets.only(left: 0.0, right: 10.0),
                  child:   TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        hintText: "My opinion about Heliopolis streets renovation",

                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical*5,),

                GestureDetector(
                  onTap: _rename,
                  child: Container(
                    height: SizeConfig.screenHeight * .06,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: green),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: whitecolor),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.navigate_next,
                              color: whitecolor,
                            )),
                      ],
                    ),
                  ),
                ),
              ])));}
void _rename(){}

Widget _deleteMessageCard(int index){
  return Container(
    height: SizeConfig.blockSizeVertical*25,
    width: SizeConfig.screenWidth-20,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    padding: EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
        color:Colors.white,
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
        _upperPart(index),
        Padding(padding: EdgeInsets.only(top: 5),
          child: _play(),
        ),

        SizedBox(height: 10,),
        _option(),
      ],


    ),

  );

}
Widget _deletePopUP(){
  return CustomDialog(height: SizeConfig.blockSizeVertical*50,
  child: Container(
    margin: EdgeInsets.symmetric(horizontal:0),
    child: Column(
      children: [
      SizedBox(
        height: 10,
      ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: (){
                AppRoutes.pop(context);

              },
           child: Icon(Icons.close),
            ),

            )
          ],
        ),
        Text('Delete',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
        SizedBox(height: SizeConfig.blockSizeVertical*3,),
        Text('Are you sure you want to delete'),
      Padding(padding: EdgeInsets.only(top: 5),),
        _deleteMessageCard(0),
        GestureDetector(
          onTap:_delte,
          child: Container(
            width: SizeConfig.screenWidth-50,
            height: 45,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            padding:EdgeInsets.only(top: 5,left: 15) ,
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.all(Radius.circular(10)),

            ),
            child: Center(
              child: Text('Delete Now',style: TextStyle(fontSize: 18,color: Colors.white),),
            ),
          ),
        ),
      ],

    ),
  ),

  );}
void _playAudio(){}
  void _delte(){}
}
