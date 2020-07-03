import 'dart:math';
import 'database/words_helper.dart';

class WordList {
  WordList._privateConstructor();
  static final WordList instance = WordList._privateConstructor();
  static List<String> _words;
  String currentWord;
  double easinessFactor = 2.5;

  Future<String> getRandomWord() async {
    if (_words != null) {
      return _words[Random().nextInt(_words.length)];
    }
    await _fillWords();
    return getRandomWord();
  }

  double length(int repetitions) {
    if (repetitions == 1) {
      return 1.0;
    }
    if (repetitions == 2) {
      return 6.0;
    }
    return this.length(repetitions - 1) * this.easinessFactor;
  }

  Future<String> getNextWord() async {
    if (_words != null) {
      return _words[Random().nextInt(_words.length)];
    }
    await _fillWords();
    return getRandomWord();
  }

  void currentResult(bool isRight) {
    if (currentWord != null) {

    }
  }
  Future _fillWords() async {
    WordsHelper wordsHelper = WordsHelper();
    List<Map<String, dynamic>> allWords = await wordsHelper.queryAllRows();
    _words = List.generate(allWords.length, (index) => allWords[index]['word']);
  }
}

bool compare(Card first, Card second) {
  return first.waitDays < second.waitDays;
}

class Card  {
  final String word;
  final String translation;
  final int waitDays;

  Card(
      this.word,
      this.translation,
      this.waitDays);
}