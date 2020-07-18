import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class TtsState {

  static FlutterTts flutterTts;

  bool playing;
  Completer completer = Completer();

  initState() async {
    flutterTts = FlutterTts();
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

  Future say(String word, String lang) async {
    TtsState ttsState = await _state.ttsState;
    await TtsState.flutterTts.setLanguage(lang);
    await TtsState.flutterTts.isLanguageAvailable(lang);
    ttsState.completer = Completer();
    assert(ttsState.playing == false);
    TtsState.flutterTts.speak(word).then((resp) {
      print("Response received after speaking: " + resp.toString());
      return resp;
    }, onError: (obj, st) {
      print(obj);
      print(st.toString());
    });
    return ttsState.completer.future;
  }

  Future stop() async {
    TtsState ttsState = await _state.ttsState;
    var result = await TtsState.flutterTts.stop();
    if (result == 1) ttsState.playing = false;
  }
}
