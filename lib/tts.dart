
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts_web.dart';


class SpeakerState extends State<Speaker> {

  FlutterTts flutterTts  = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  Completer completer;

  @override
  initState() {
    super.initState();
    flutterTts  = FlutterTts();
    ttsState = TtsState.stopped;
    flutterTts.setStartHandler(() {
      setState(() {
        assert(ttsState == TtsState.stopped);
        ttsState = TtsState.playing;
        completer = Completer();
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        assert(ttsState == TtsState.playing);
        ttsState = TtsState.stopped;
        completer.complete(ttsState);
      });
    });
  }

  Future say(String word) {
    assert(ttsState == TtsState.stopped);
    flutterTts.speak(word).then((resp) {
      print(resp);
      return resp;
    }, onError: (obj, st) {
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
