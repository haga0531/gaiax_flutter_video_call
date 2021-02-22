import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:permission_handler/permission_handler.dart';

class OnCall extends StatefulWidget {
  @override
  _OnCallState createState() => _OnCallState();
}

class _OnCallState extends State<OnCall> {
  bool _joined = false;
  int _remoteUid = null;
  bool _switch = false;
  RtcEngine _rtcEngine;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
    // TODO: envが読み込めない。。。出力値は同じのはずなのに。。
    _rtcEngine = await RtcEngine.create('1b586c670405410b946dffc0b66af921');
    _rtcEngine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      setState(() {
        _remoteUid = null;
      });
    }));
    await _rtcEngine.enableVideo();
    await _rtcEngine.joinChannel(DotEnv.env['Token'], 'room1', null, 0);
  }

  void exitRoom() {
    _rtcEngine.leaveChannel();
    _rtcEngine.destroy();
    Navigator.pop(context);
  }

  Widget _rowLayout() {
    if (_remoteUid != null) {
      return Container(
        child: Column(
          children: [
            Expanded(child: _renderRemoteVideo()),
            Expanded(child: _renderLocalPreview()),
          ],
        ),
      );
    }
    return Container(
      child: Column(
        children: [Expanded(child: _renderLocalPreview())],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('room1'), // TODO: 動的に渡したい
        ),
        body: Stack(children: [
          _rowLayout(),
          new Container(child: SizedBox(
            child: new RaisedButton(onPressed: () {
              exitRoom();
            },
            child: Text("Stop Video Call", style: TextStyle(color: Colors.white, fontSize: 20),),
                color: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            width: 300,
          ),
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 40),
          ) 
        ]),
      ),
    );
  }

  _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
}
