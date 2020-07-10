import 'dart:math';
import 'database/words_helper.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:owl/database/words_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

class WordList {
  WordList._privateConstructor();
  static final WordList instance = WordList._privateConstructor();
  static final listenModeBatchSize = 5;
  static final repetitionTimesPerBatch = 2;
  static List<int> _listenModeSchedule;
  static List<dynamic> _words;
  int currentIndex = -1;
  int currentBatchStart = -1;
  int currentBatchRepetitions = -1;
  int currentIndexInBatch = -1;
  bool reachedEndInListenMode = false;
  int myDid = -1;
  Levenshtein d = new Levenshtein();
  bool prevousWasWord = false;
  bool listenMode = true;
  var rng = new Random(new DateTime.now().millisecondsSinceEpoch);
  // TODO(affina73): move support of the listenMode higher

  void setListenMode(bool listenMode) {
    this.listenMode = listenMode;
  }

  Future<String> getNextWord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    listenMode = prefs.getBool(ConstVariables.listen_mode);
    if (_words == null || myDid != prefs.getInt(ConstVariables.current_dictionary_id)) {
      myDid = prefs.getInt(ConstVariables.current_dictionary_id);
      await _fillWords();
    }
    if (listenMode && prevousWasWord) {
      prevousWasWord = false;
      return this._getNextTranslation();
    }
    _updateCurrentIndex();
    print("current index: " + currentIndex.toString());
    return this._getNextWord();
  }

  void _updateCurrentIndex() {
    print("update current index");
    print("listen mode");
    print(listenMode);
    print(currentIndexInBatch);
    print(_listenModeSchedule);
    if (listenMode) {
      if (_listenModeSchedule == null) {
        _regenerateScheduleInListenMode();
      }
      if (currentIndexInBatch == -1) {
        currentIndexInBatch = 0;
      }
      currentIndexInBatch += 1;
      if (currentIndexInBatch == _listenModeSchedule.length) {
        currentBatchRepetitions += 1;
        currentIndexInBatch = 0;
        if (currentBatchRepetitions >= repetitionTimesPerBatch) {
          _regenerateScheduleInListenMode();
        }
      }
      currentIndex = _listenModeSchedule[currentIndexInBatch];
    } else {
      currentIndex = (currentIndex + 1) % _words.length;
    }
  }

  void _regenerateScheduleInListenMode() {
    print("regenerate schedule");
    if (currentBatchStart == -1) {
      currentBatchStart = 0;
      currentBatchRepetitions = 0;
    }
    if (currentBatchRepetitions == repetitionTimesPerBatch) {
      currentBatchStart += listenModeBatchSize;
      currentBatchRepetitions = 0;
    }
    int currentBatchEnd = min(
        currentBatchStart + listenModeBatchSize, _words.length);
    if ((currentBatchStart >= _words.length) || reachedEndInListenMode) {
      reachedEndInListenMode = true;
      currentBatchStart = 0;
      currentBatchEnd = _words.length;
    }
    _listenModeSchedule = [
      for(var i=currentBatchStart; i<currentBatchEnd; i++) i];
    _listenModeSchedule.shuffle(rng);
    print(_listenModeSchedule);
  }

  Future<String> _getNextWord() async {
    return _words[currentIndex]["word"];
  }

  String _getNextTranslation() {
    return _words[currentIndex]["translation"];
  }

  void _updateCurrentResult(String saidWord) {
    if (currentIndex != -1) {
      // https://www.supermemo.com/en/archives1990-2015/english/ol/sm2
      // q = quality of the response from 0 to 5
      // EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
      // EF < 1.3 => EF==1.3;
      // quality < 3 => repetitions := 0;
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
      nextDate = nextDate + _getInterval(
          _words[currentIndex]["repetitions"],
          _words[currentIndex]["ef"]) - 1;
      // TODO(affina73): here we should make some db updates for ef, rep, date

    }
  }

  void _clear() {
    currentIndex = -1;
    prevousWasWord = false;
    currentBatchStart = -1;
    currentBatchRepetitions = -1;
    currentIndexInBatch = -1;
    reachedEndInListenMode = false;
    _listenModeSchedule = null;
  }

  Future _fillWords() async {
    _clear();
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

  static int _getInterval(int repetitions, double ef) {
    if (repetitions == 1) {
      return 1;
    }
    if (repetitions == 2) {
      return 4;
    }
    // l(n) = l(n - 1) * ef
    return (pow(ef, repetitions - 2) * 4).round();
  }
}

int compare(dynamic first, dynamic second) {
  return first["next_date"].compareTo(second["next_date"]);
}

int timeToInt(DateTime dateTime) {
  return (dateTime.millisecondsSinceEpoch / (1000000 * 60 * 60 * 24)).round();
}