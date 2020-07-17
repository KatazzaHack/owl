import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'dart:async';

import 'package:owl/word_scheduler.dart';
import 'package:owl/tts/tts_helper.dart';
import 'package:owl/stt/stt_helper.dart';
import 'package:owl/settings/settings.dart';


class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {
  WordScheduler wl = WordScheduler.instance;

  final StreamController<String> _streamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    initStream();
  }

  void initStream() {
    _streamController.addStream((() async* {
      List<String> languages = ["de-DE", "ru-RU"];
      List<String> locales = ["de_DE", "ru_RU"];
      int currentLanguageIndex = 0;
      int targetLanguageIndex = 1 - currentLanguageIndex;
      for (var i = 0;; i++) {
        String word = await wl.getNextWord();
        yield word;

        await TtsHelper().say(word, languages[currentLanguageIndex]);
        print("Saying future completed");
        print("Waiting for user input...");
        if (Settings().listen) {
          String parsedWords = await SttHelper().listen(
              locales[targetLanguageIndex]);
          // Wait till user is suggested translation.
          print(
              "Finished waiting for user input, parsed words are " + parsedWords);
          int quality = await wl.obtainCurrentResult(parsedWords);
          print(quality);
        }
        String correctTranslation = wl.getNextTranslation();
        yield correctTranslation;
        await TtsHelper().say(correctTranslation,
          languages[targetLanguageIndex]);
      }
    })());
    print("initStream finished");
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
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: AutoSizeText("${snapshot.data}",
                              style: TextStyle(fontSize: 100), maxLines: 1)
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: RaisedButton(
                                  shape: CircleBorder(),
                                  color: Colors.red,
                                  onPressed: () {
                                    TtsHelper().stop();
                                    SttHelper().stop();
                                    Navigator.pop(context);
                                  },
                                  child: AutoSizeText(
                                    "STOP",
                                    style: TextStyle(fontSize: 20),
                                    maxLines: 1,
                                  ))),
                        ])));
          } else {
            return LinearProgressIndicator();
          }
        });
  }
}
