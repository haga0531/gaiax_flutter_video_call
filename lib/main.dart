import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:gaiax_flutter_video_call/pages/call_video.dart';
import 'package:gaiax_flutter_video_call/pages/on_call.dart';

Future main() async {
  await DotEnv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Call',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          )
        )
      ),
      home: VideoCall(),
      routes: <String, WidgetBuilder>{
        '/video_call_room': (BuildContext context) => new OnCall()
      },
    );
  }
}