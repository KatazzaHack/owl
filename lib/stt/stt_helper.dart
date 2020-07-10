import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SttState {
  static stt.SpeechToText speech;

  Completer<String> completer = Completer<String>();
//  List<LocaleName> _localeNames = [];

  initState() async {
    speech = stt.SpeechToText();
    bool available = await speech.initialize(
        onStatus: statusListener, onError: errorListener);
    if (available) {
      print("Stt is available");
    } else {
      print("The user has denied the use of speech recognition");
    }

    // TODO(okalitova): Use it.
//    _localeNames = await speech.locales();
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
  }

  void statusListener(String status) {
    print(
        "Received listener status: $status, listening: ${speech.isListening}");
  }
}

class SttStateSingleton {
  // make this a singleton class
  SttStateSingleton._privateConstructor();

  static final SttStateSingleton instance =
      SttStateSingleton._privateConstructor();

  // only have a single app-wide reference to the database
  static SttState _sttState;

  Future<SttState> get sttState async {
    if (_sttState != null) return _sttState;
    // lazily instantiate the db the first time it is accessed
    _sttState = SttState();
    await _sttState.initState();
    return _sttState;
  }
}

class SttHelper {
  static SttStateSingleton _state = SttStateSingleton.instance;

  SttState _sttState;

  Future<String> listen(String locale) async {
    _sttState = await _state.sttState;
    print("Start listening in locale " + locale + "...");
    SttState.speech.listen(onResult: resultListener, localeId: locale);
    print("Starting waiting for input");
    _sttState.completer = Completer<String>();
    return _sttState.completer.future;
  }

  void resultListener(SpeechRecognitionResult result) {
    print("${result.recognizedWords} - ${result.finalResult}");
    if (result.finalResult) {
      print("Stopped listening");
      SttState.speech.stop();
      _sttState.completer.complete(result.recognizedWords);
    }
  }

  Future stop() async {
    _sttState = await _state.sttState;
    await SttState.speech.stop();
  }
}
