
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soundpool/soundpool.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:owl/database/words_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:owl/word_scheduler.dart';
import 'package:owl/tts/tts_helper.dart';
import 'package:owl/stt/stt_helper.dart';
import 'package:owl/start_page/settings.dart';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {
  WordScheduler wl = WordScheduler.instance;
  Soundpool pool = Soundpool(streamType: StreamType.notification);
  final assetsAudioPlayer = AssetsAudioPlayer();

  final StreamController<WordWithResult> _streamController =
      StreamController<WordWithResult>();

  @override
  void initState() {
    super.initState();
    initStream();
  }

  void initStream() {
    _streamController.addStream((() async* {
      WordsHelper _wH = WordsHelper();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Language lOriginal = ConstVariables.reverse_human_languages[
          prefs.getString(ConstVariables.original_language)];
      Language lTranslate = ConstVariables.reverse_human_languages[
          prefs.getString(ConstVariables.translate_language)];
      if (!prefs.containsKey(ConstVariables.speed_id)) {
        prefs.setInt(ConstVariables.speed_id, 2);
      }
      int _speed = prefs.getInt(ConstVariables.speed_id);
      List<String> languages = [
        lOriginal.supportedLanguage, lTranslate.supportedLanguage,
      ];
      List<String> locales = [
        lOriginal.supportedLocale, lTranslate.supportedLocale
      ];
      print(locales);
      print(languages);
      int currentLanguageIndex = 0;
      int targetLanguageIndex = 1 - currentLanguageIndex;
      int quality = -1;
      ByteData okByteData = await rootBundle.load('assets/sounds/ok.mp3');
      ByteData badByteData = await rootBundle.load('assets/sounds/bad.mp3');
      int okSoundId = await pool.load(okByteData);
      int badSoundId = await pool.load(badByteData);
      for (var i = 0;; i++) {
        String word = await wl.getNextWord();
        await new Future.delayed(Duration(seconds: 1));
        yield WordWithResult(
            /* isTranslation = */ false,
            /* text = */ word,
            /* listeningResult = */ ListeningResult.undefined);

        await TtsHelper().say(word, languages[currentLanguageIndex]);
        print("Saying future completed");
        if (Settings().practiceMod) {
          print("Waiting for user input...");
          String parsedWords =
              await SttHelper().listen(locales[targetLanguageIndex], _speed);
          // Wait till user is suggested translation.
          print("Finished waiting for user input, parsed words are " +
              parsedWords);
          if (parsedWords != null) {
            FLog.logThis(
              className: "StopPage",
              methodName: "initStream",
              text: "parsed words: " + parsedWords.toString(),
              type: LogLevel.INFO,
              dataLogType: DataLogType.DEVICE.toString(),
            );
          }
          quality = await wl.updateWithAnswer(parsedWords);
          if (quality == 5 || quality == 4) {
            pool.play(okSoundId);
          } else {
            pool.play(badSoundId);
          }
        } else {
          await new Future.delayed(Duration(seconds: _speed));
        }
        String correctTranslation = wl.getNextTranslation();
        yield WordWithResult(
            /* isTranslation = */ true,
            /* text = */ correctTranslation,
            /* listeningResult = */ convertQualityToResult(quality));

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
    return StreamBuilder<WordWithResult>(
        stream: _streamController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<WordWithResult> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                body: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Spacer(flex: 1),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: AutoSizeText("${snapshot.data.text}",
                                style: TextStyle(
                                  fontSize: 100,
                                  color: getColorFromWordResult(snapshot.data),
                                ),
                                maxLines: 1)),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
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
                    Spacer(flex: 1),
                  ]),
            ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class WordWithResult {
  bool isTranslation = false;
  String text = "";
  ListeningResult listeningResult = ListeningResult.undefined;

  WordWithResult(this.isTranslation, this.text, this.listeningResult);
}

enum ListeningResult { bad, medium, perfect, undefined }

Color getColorFromWordResult(WordWithResult wordWithResult) {
  if (wordWithResult.isTranslation) {
    switch (wordWithResult.listeningResult) {
      case ListeningResult.bad:
        return Colors.red;
      case ListeningResult.medium:
        return Colors.yellow;
      case ListeningResult.perfect:
        return Colors.green;
      default:
        return Colors.black;
    }
  }
  return Colors.black;
}

ListeningResult convertQualityToResult(int quality) {
  switch (quality) {
    case 0:
      return ListeningResult.bad;
    case 1:
      return ListeningResult.bad;
    case 2:
      return ListeningResult.bad;
    case 3:
      return ListeningResult.bad;
    case 4:
      return ListeningResult.medium;
    case 5:
      return ListeningResult.perfect;
  }
  return ListeningResult.undefined;
}
