import 'package:flutter/material.dart';
import 'package:gaiax_flutter_video_call/pages/on_call.dart';

class VideoCall extends StatefulWidget {
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final inputRoomIdController = TextEditingController();
  String _inputChannelName;
  bool _isEnabled = false;

  @override
  void dispose() {
    inputRoomIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    inputRoomIdController.addListener(validRoomId);
  }

  validRoomId() {
    if (inputRoomIdController.text.isNotEmpty) {
      setState(() {
        _isEnabled = true;
      });
    } else {
      setState(() {
        _isEnabled = false;
      });
    }
  }

  onEnterRoom() async {
    var channelName = _inputChannelName != null ? _inputChannelName : 'room1';
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OnCall(channelName: channelName)));
  }

  Widget _layout() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Video Call"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Video Call',
              textScaleFactor: 2,
            ),
            // Container(
            //     child: ButtonTheme(
            //   minWidth: 280.0,
            //   height: 60.0,
            //   child: RaisedButton(
            //     elevation: 10.0,
            //     child: Text(
            //       "Start Video Call",
            //       style: TextStyle(fontSize: 25),
            //     ),
            //     onPressed: () {
            //       onEnterRoom();
            //     },
            //     color: Colors.orange,
            //     textTheme: ButtonTextTheme.primary,
            //   ),
            // )),
            // SizedBox(
            //   height: 50,
            // ),
            Container(
              width: 280,
              child: TextField(
                controller: inputRoomIdController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'ルームIDを入力'),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                child: ButtonTheme(
              minWidth: 280.0,
              height: 60.0,
              child: RaisedButton(
                elevation: 10.0,
                child: Text(
                  "Join Video Call",
                  style: TextStyle(fontSize: 25),
                ),
                onPressed: !_isEnabled
                    ? null
                    : () {
                        setState(() {
                          _inputChannelName = inputRoomIdController.text.trim();
                          inputRoomIdController.text = '';
                        });
                        onEnterRoom();
                      },
                color: Colors.orange,
                textTheme: ButtonTextTheme.primary,
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _layout();
  }
}
