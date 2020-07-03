import 'dart:math';
import 'package:owl/database/words_helper.dart';

class WordList {
  WordList._privateConstructor();
  static final WordList instance = WordList._privateConstructor();
  static List<dynamic> _words;
  String currentWord;
  int dayLimit = 5;
  int currentIndex = -1;

  int getInterval(int repetitions, double ef) {
    if (repetitions == 1) {
      return 1;
    }
    if (repetitions == 2) {
      return 6;
    }
    return (pow(ef, repetitions - 2) * 6).round();
  }

  Future<String> getNextWord() async {
    if (_words == null) {
      await _fillWords();
    }
    if (currentIndex == _words.length) {
      return Future.value(null);
    }
    currentIndex++;
    currentWord = _words[currentIndex]["word"];
    return Future.value(currentWord);
  }

  void updateCurrentResult(bool isRight) {
    if (currentWord != null) {
      // TODO(affina73): here we should make some db updates
      if (!isRight) {
        _words.add(_words[currentIndex]);
      }
    }
  }

  Future _fillWords() async {
    WordsHelper wordsHelper = WordsHelper();
    List<Map<String, dynamic>> allWords = await wordsHelper.getCurrentWords();
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
  return (dateTime.millisecondsSinceEpoch / 1000000).round();
}