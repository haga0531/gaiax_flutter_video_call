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
  RtcEngine _rtcEngine;
  final _users = <int>[];
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  genToken(uid) async {
    String token;
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
      // localUserのtrigger
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        setState(() {
          _joined = true;
        });
      },
      userJoined: (int uid, int elapsed) {
        // remoteUserのtrigger
        setState(() {
          _users.add(uid);
        });
      },
      userOffline: (int uid, UserOfflineReason reason) {
        setState(() {
          _users.remove(uid);
        });
      },
    ));
    await _rtcEngine.enableVideo();
    await _rtcEngine.joinChannel(token, '${widget.channelName}', null, uid);
  }

  void exitRoom() {
    _rtcEngine.leaveChannel();
    _rtcEngine.destroy();
    Navigator.pop(context);
  }

  List<Widget> _renderViewList() {
    final List<Widget> viewList = [];
    viewList.add(RtcLocalView.SurfaceView());
    _users.forEach(
        (int uid) => viewList.add(RtcRemoteView.SurfaceView(uid: uid)));
    return viewList;
  }

  Widget _expandedView(List<Widget> views) {
    final viewList = views.map<Widget>(_view).toList();
    return Expanded(
      child: Row(
        children: viewList,
      ),
    );
  }

  Widget _view(view) {
    return Expanded(
        child: Container(
      child: view,
    ));
  }

  // 自分を画面右下にするための実装
  List<Widget> _reverseViewList(List<Widget> view) {
    return view.reversed.toList();
  }

  Widget _rowLayout() {
    final viewList = _renderViewList();

    // UI的にcaseが増えることはないからハードコードで良さそう.
    switch (viewList.length) {
      case 1:
        return _joined
            ? Container(
                // ここでflagを持たせることでいい感じにカメラがつくようになった
                child: Column(
                children: [_view(viewList[0])],
              ))
            : Container(child: Text('Loading...'));
      case 2:
        return Container(
            child: Column(
          children: [
            _expandedView([viewList[1]]),
            _expandedView([viewList[0]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: [
            _expandedView(viewList.sublist(2, 3)),
            _expandedView(_reverseViewList(viewList.sublist(0, 2))),
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: [
            _expandedView(viewList.sublist(2, 4)),
            _expandedView(_reverseViewList(viewList.sublist(0, 2)))
          ],
        ));
      default:
    }
    return Container();
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
}
