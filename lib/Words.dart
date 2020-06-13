import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

class WordList {
  WordList._privateConstructor();
  static final WordList instance = WordList._privateConstructor();
  static List<String> _words;

  Future<String> getRandomWord() async {
    if (_words != null) {
      return _words[Random().nextInt(_words.length)];
    }
    await _fillWords();
    return getRandomWord();
  }

  Future _fillWords() async {
    String words = await rootBundle.loadString('assets/words.txt');
    _words = words.split("\n");
  }
}