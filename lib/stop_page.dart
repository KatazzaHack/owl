import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

import 'dart:async';

import 'package:owl/words.dart';
import 'package:owl/tts/tts_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {
  stt.SpeechToText speech;
  WordList wl = WordList.instance;
  Completer listenCompleter = Completer();
  Future<void> _listeningFinished;
  List<LocaleName> _localeNames = [];

  final StreamController<String> _streamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    initStt();
    initStream();
    initListenModeCheck();
  }

  void initListenModeCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(ConstVariables.listen_mode, true);
  }

  void initStt() async {
    speech = stt.SpeechToText();
    bool available = await speech.initialize(onStatus: statusListener, onError: errorListener);
    if ( available ) {
      print("Stt is available");
    } else {
      print("The user has denied the use of speech recognition");
    }

    _localeNames = await speech.locales();
//    for (LocaleName locale in _localeNames) {
//      print(locale.localeId);
//    }
  }

  void initStream() {
    _streamController.addStream((() async* {
      List<String> languages = ["de-DE", "ru-RU"];
      List<String> locales = ["de_DE", "ru_RU"];
      int currentLanguageIndex = 0;
      for (var i = 0;; i++) {
        String word = await wl.getNextWord();
        yield word;

        Future<void> future = TtsHelper().say(word, languages[currentLanguageIndex]);
        currentLanguageIndex = 1 - currentLanguageIndex;
        future.then((_) => {
            print("Saying future completed"),
            _listeningFinished = startListen(locales[1 - currentLanguageIndex])
        })
            .catchError((error) => print("Error happend"));
        // Wait till original word is said.
        await future;
        // Wait till user is suggested translation.
        print("Waiting for user input...");
        await _listeningFinished;
        print("Finished waiting for user input");
      }
    })());
    print("initStream finished");
  }

  Future<void> startListen(String locale) async {
    print("Start listening in locale " + locale + "...");
    speech.listen( onResult: resultListener, localeId: locale);
    print("Starting waiting for input");
    listenCompleter = Completer();
    return listenCompleter.future;
  }

  void resultListener(SpeechRecognitionResult result) {
    print("${result.recognizedWords} - ${result.finalResult}");
    if (result.finalResult) {
      print("Stopped listening");
      speech.stop();
      listenCompleter.complete();
    }
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
  }

  void statusListener(String status) {
     print("Received listener status: $status, listening: ${speech.isListening}");
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                body: Container(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AutoSizeText("${snapshot.data}",
                              style: TextStyle(fontSize: 100), maxLines: 1),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: RaisedButton(
                                  shape: CircleBorder(),
                                  color: Colors.red,
                                  onPressed: () {
                                    TtsHelper().stop();
                                    Navigator.pop(context);
                                  },
                                  child: AutoSizeText(
                                    "STOP",
                                    style: TextStyle(fontSize: 20),
                                    maxLines: 1,
                                  ))),
                        ])));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
