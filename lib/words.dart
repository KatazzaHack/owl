import 'dart:math';
import 'database/words_helper.dart';

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
    WordsHelper wordsHelper = WordsHelper();
    List<Map<String, dynamic>> allWords = await wordsHelper.queryAllRows();
    _words = List.generate(allWords.length, (index) => allWords[index]['word']);
  }
}