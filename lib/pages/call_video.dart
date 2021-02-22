import 'package:flutter/material.dart';

class VideoCall extends StatefulWidget {
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  TextEditingController _controller;
  int _inputRoomId = 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  onEnterRoom(roomId) async {
    Navigator.pushNamed(context, '/video_call_room');
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
            Container(
                child: ButtonTheme(
              minWidth: 280.0,
              height: 60.0,
              child: RaisedButton(
                elevation: 10.0,
                child: Text(
                  "Start Video Call",
                  style: TextStyle(fontSize: 25),
                ),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  onEnterRoom(1);
                },
                color: Colors.orange,
                textTheme: ButtonTextTheme.primary,
              ),
            )),
            SizedBox(
              height: 50,
            ),
            Container(
              width: 280,
              child: TextField(
                controller: _controller,
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
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    _inputRoomId = int.parse(_controller.text);
                    _controller.text = '';
                  });
                  onEnterRoom(_inputRoomId);
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
