import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:owl/database/words_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

import 'dart:async';

import 'package:owl/word_scheduler.dart';
import 'package:owl/tts/tts_helper.dart';
import 'package:owl/stt/stt_helper.dart';
import 'package:owl/settings/settings.dart';
import 'package:f_logs/f_logs.dart';

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
      WordsHelper _wH = WordsHelper();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      SupportedLanguage lOriginal = ConstVariables.reverse_human_languages[
          prefs.getString(ConstVariables.original_language)];
      SupportedLanguage lTranslate = ConstVariables.reverse_human_languages[
          prefs.getString(ConstVariables.translate_language)];
      List<String> languages = [
        ConstVariables.supported_languages[lOriginal],
        ConstVariables.supported_languages[lTranslate]
      ];
      List<String> locales = [
        ConstVariables.supported_locales[lOriginal],
        ConstVariables.supported_locales[lTranslate]
      ];
      print(locales);
      print(languages);
      int currentLanguageIndex = 0;
      int targetLanguageIndex = 1 - currentLanguageIndex;
      for (var i = 0;; i++) {
        String word = await wl.getNextWord();
        yield word;

        await TtsHelper().say(word, languages[currentLanguageIndex]);
        print("Saying future completed");
        print("Waiting for user input...");
        if (Settings().listen) {
          String parsedWords =
              await SttHelper().listen(locales[targetLanguageIndex]);
          // Wait till user is suggested translation.
          print("Finished waiting for user input, parsed words are " +
              parsedWords);
          FLog.logThis(
            className: "StopPage",
            methodName: "initStream",
            text: "parsed words: " + parsedWords.toString(),
            type: LogLevel.INFO,
            dataLogType: DataLogType.DEVICE.toString(),
          );
          int quality = await wl.obtainCurrentResult(parsedWords);
          print(quality);
        }
        String correctTranslation = wl.getNextTranslation();
        yield correctTranslation;
        await TtsHelper()
            .say(correctTranslation, languages[targetLanguageIndex]);
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
                          Spacer (flex:1),
                          Expanded (
                            flex: 1,
                            child:
                                Center(
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: AutoSizeText("${snapshot.data}",
                                    style: TextStyle(fontSize: 100),
                                    maxLines: 1)),
                                ),
                          ),
                          Expanded (
                            flex: 1,
                            child:
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.2,
                                child: RaisedButton(
                                    shape: CircleBorder(),
                                    color: Colors.red,
                                    onPressed: () async {
                                      TtsHelper().stop();
                                      SttHelper().stop();
                                      Navigator.pop(context);
                                      FLog.exportLogs();
                                    },
                                    child: AutoSizeText(
                                      "STOP",
                                      style: TextStyle(fontSize: 20),
                                      maxLines: 1,
                                    ))),
                          ),
                          Spacer (flex:1),
                        ]),

                ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
