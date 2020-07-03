
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class TtsState {

  static FlutterTts flutterTts;

  bool playing;
  Completer completer;

  initState() async {
    flutterTts = FlutterTts();

    await flutterTts.setLanguage("en-US");
    await flutterTts.isLanguageAvailable("en-US");
    playing = false;
    flutterTts.setStartHandler(() {
      assert(playing == false);
      playing = true;
    });
    flutterTts.setCompletionHandler(() {
      assert(playing == true);
      playing = false;
      completer.complete();
    });
  }
}

class TtsStateSingleton {
  // make this a singleton class
  TtsStateSingleton._privateConstructor();

  static final TtsStateSingleton instance = TtsStateSingleton._privateConstructor();

  // only have a single app-wide reference to the database
  static TtsState _ttlState;

  Future<TtsState> get ttsState async {
    if (_ttlState != null) return _ttlState;
    // lazily instantiate the db the first time it is accessed
    _ttlState = TtsState();
    await _ttlState.initState();
    return _ttlState;
  }
}

class TtsHelper {

  static TtsStateSingleton _state = TtsStateSingleton.instance;


  Future say(String word) async {
    TtsState ttsState = await _state.ttsState;
    ttsState.completer = Completer();
    assert(ttsState.playing == false);
    TtsState.flutterTts.speak(word).then((resp) {
      print(resp);
      return resp;
    }, onError: (obj, st) {
      print(obj);
      print(st.toString());
    });
    return ttsState.completer.future;
  }
}