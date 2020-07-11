import 'dart:math';
import 'database/words_helper.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:owl/database/words_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/utils.dart';

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
  int insertWrongAnsweredDistance = 10;
  bool reachedEndInListenMode = false;
  int myDid = -1;
  Levenshtein d = new Levenshtein();
  bool prevousWasWord = false;
  bool listenMode = true;
  var rng = new Random(new DateTime.now().millisecondsSinceEpoch);
  WordsHelper wordsHelper = WordsHelper();
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
    print("listen mode:" + listenMode.toString());
    if (listenMode) {
      print("current index in batch:" + currentIndexInBatch.toString());
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
      print("words:" + _words.length.toString());
      currentIndex = (currentIndex + 1) % _words.length;
    }
  }

  void _regenerateScheduleInListenMode() {
    print("regenerate schedule");
    print("Current schedule is:");
    print(_listenModeSchedule);
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

  String _getNextWord() {
    return _words[currentIndex]["word"];
  }

  String _getNextTranslation() {
    return _words[currentIndex]["translation"];
  }

  Future<int> updateCurrentResult(String saidWord) {
    assert(currentIndex != -1);
    // https://www.supermemo.com/en/archives1990-2015/english/ol/sm2
    // q = quality of the response from 0 to 5
    // EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
    // EF < 1.3 => EF==1.3;
    // quality < 3 => repetitions := 0;
    // never called in listenMode
    print("Said word: " + saidWord);
    print("True word: " +  _words[currentIndex]["translation"]);
    Map<String, dynamic> newRecord = new Map.from(_words[currentIndex]);
    int responseDistance = d.distance(
        saidWord, _words[currentIndex]["translation"]);
    print("Response distance: " +  responseDistance.toString());
    int quality = 5 - ((5.0 * responseDistance)
            / _words[currentIndex]["translation"].length)
            .round();
    quality = max(quality, 0);
    quality = min(quality, 5);
    print("quality: " +  quality.toString());
    print("previous ef: " + _words[currentIndex]["ef"].toString());
    double ef = _words[currentIndex]["ef"]
        + (0.1 - (5 - quality) * (0.08 + quality * 0.02));
    print("ef: " +  ef.toString());
    newRecord["ef"] = ef;
    if (ef < 1.3) {
      ef = 1.3;
    }
    int repetitions = _words[currentIndex]["repetitions"] + 1;
    newRecord["repetitions"] = repetitions;
    print("repetitions: " +  repetitions.toString());
    if (quality <= 3) {
      repetitions = 0;
      _words.insert(
          currentIndex + insertWrongAnsweredDistance,
          _words[currentIndex]);
    }
    int nextDate = _words[currentIndex]["next_date"];
    print("nextDate: " +  nextDate.toString());
    nextDate = timeToInt(DateTime.now()) + _getInterval(
        _words[currentIndex]["repetitions"],
        _words[currentIndex]["ef"]);
    newRecord["next_date"] = nextDate;
    print("new nextDate: " +  nextDate.toString());
    print("today: " +  timeToInt(DateTime.now()).toString());
    print("reached end of the update");
    return wordsHelper.updateOneRecord(newRecord);
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