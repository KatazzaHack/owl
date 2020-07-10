import 'dart:math';
import 'database/words_helper.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:owl/database/words_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

class WordList {
  WordList._privateConstructor();
  static final WordList instance = WordList._privateConstructor();
  static List<dynamic> _words;
  int dayLimit = 5;
  int currentIndex = -1;
  int myDid = -1;
  Levenshtein d = new Levenshtein();
  bool prevousWasWord = false;
  var rng = new Random(new DateTime.now().millisecondsSinceEpoch);
  // TODO(affina73): move support of the listenMode higher

  int getInterval(int repetitions, double ef) {
    if (repetitions == 1) {
      return 1;
    }
    if (repetitions == 2) {
      return 4;
    }
    // l(n) = l(n - 1) * ef
    return (pow(ef, repetitions - 2) * 4).round();
  }
  Future<String> getNextWord(bool listenMode) async {
    print("next word asked");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_words == null || myDid != prefs.getInt(ConstVariables.current_dictionary_id)) {
      myDid = prefs.getInt(ConstVariables.current_dictionary_id);
      await _fillWords();
    }
    if (currentIndex == -1) {
      currentIndex = rng.nextInt(_words.length) % _words.length;
    }
    if (currentIndex == _words.length) {
      currentIndex = -1;
      myDid = prefs.getInt(ConstVariables.current_dictionary_id);
    }
    print("current index");
    print(currentIndex);
    if (listenMode && prevousWasWord) {
      print("current index in translation");
      print(currentIndex);
      prevousWasWord = false;
      return this._getNextTranslation();
    } else {
      print("current index in word");
      print(currentIndex);
      print(_words.length);
      print((rng.nextInt(_words.length)) % _words.length);
      currentIndex = rng.nextInt(_words.length) % _words.length;
      prevousWasWord = true;
      return this._getNextWord();
    }
  }

  Future<String> _getNextWord() async {
    return Future.value(_words[currentIndex]["word"]);
  }

  Future<String> _getNextTranslation() async {
    return Future.value(_words[currentIndex]["translation"]);
  }

  void updateCurrentResult(String saidWord) {
    if (currentIndex != -1) {
      // https://www.supermemo.com/en/archives1990-2015/english/ol/sm2
      // q = quality of the response from 0 to 5
      // EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
      // EF < 1.3 => EF==1.3;
      //quality < 3 => repetitions := 0;
      // never called in listenMode??
      int responseDistance = d.distance(saidWord, _words[currentIndex]["word"]);
      int quality = (5.0 * responseDistance
          / _words[currentIndex]["word"]).round();
      double ef = _words[currentIndex]["ef"]
          + (0.1 - quality * (0.08 + quality * 0.02));
      if (ef < 1.3) {
        ef = 1.3;
      }
      int repetitions = _words[currentIndex]["repetitions"] + 1;
      if ((5 - quality) <= 3) {
        repetitions = 0;
        _words.add(_words[currentIndex]);
      }
      int nextDate = _words[currentIndex]["next_date"];
      nextDate = nextDate + getInterval(
          _words[currentIndex]["repetitions"],
          _words[currentIndex]["ef"]) - 1;
      // TODO(affina73): here we should make some db updates for ef, rep, date

    }
  }

  Future _fillWords() async {
    currentIndex = -1;
    prevousWasWord = false;
    WordsHelper wordsHelper = WordsHelper();
    List<Map<String, dynamic>> allWords = await wordsHelper.getCurrentWords();
    print("all words awaited");
    _words = new List();
    for (var j = 0; j < allWords.length; j++) {
      if (allWords[j]["next_date"] <= timeToInt(DateTime.now())) {
        _words.add(allWords[j]);
      }
    }
  }
}

int compare(dynamic first, dynamic second) {
  return first["next_date"].compareTo(second["next_date"]);
}

int timeToInt(DateTime dateTime) {
  return (dateTime.millisecondsSinceEpoch / (1000000 * 60 * 60 * 24)).round();
}