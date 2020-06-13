
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter/material.dart';


class SpeakerState extends State<Speaker> {

  FlutterTts flutterTts = FlutterTts();
  bool playing;
  Completer completer;

  @override
  initState() {
    super.initState();
    bool playing = false;
    flutterTts.setStartHandler(() {
      setState(() {
        print('start saying');
        assert(playing == false);
        playing = true;
        completer = Completer();
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        assert(playing == true);
        playing = false;
        print('saying complete');
        completer.complete();
      });
    });
  }

  Future say(String word) async {
    print("Inside say");
    assert(playing == false);
    flutterTts.speak(word).then((resp) {
      print("Inside success");
      print(resp);
      return resp;
    }, onError: (obj, st) {
      print("Inside error");
      print(obj);
      print(st.toString());
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }

}
class Speaker extends StatefulWidget  {
  final SpeakerState state = SpeakerState();

  Future say(String word) {
    return state.say(word);
  }
  @override
  SpeakerState createState() => state;
}
