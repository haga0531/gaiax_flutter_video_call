import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class OnCall extends StatefulWidget {
  final String channelName;

  const OnCall({Key key, this.channelName}) : super(key: key);
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

  genToken(uid) async {
    String token;
    // const url = 'http://localhost:8080/api';
    const url = 'https://agora-node-server.herokuapp.com/api';

    var response = await http.post(url,
        body: {'channelName': '${widget.channelName}', 'uid': '$uid'});

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      token = jsonResponse['token'];
    } else {
      print('failed generate token');
    }
    return token;
  }

  Future<void> initPlatformState() async {
    final String appId = env['APP_ID'];

    var randomInt = new Random();
    var uid = randomInt.nextInt(100);
    var token = await genToken(uid);

    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );

    _rtcEngine = await RtcEngine.create(appId);
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
    await _rtcEngine.joinChannel(token, '${widget.channelName}', null, uid);
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
    final String roomId = widget.channelName;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: new Text(roomId),
        ),
        body: Stack(children: [
          _rowLayout(),
          new Container(
            child: SizedBox(
              child: new RaisedButton(
                onPressed: () {
                  exitRoom();
                },
                child: Text(
                  "Stop Video Call",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
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

  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        '読み込み中...',
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
