import 'dart:math';
import 'database/words_helper.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:f_logs/f_logs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/words_helper.dart';
import 'package:owl/utils.dart';
import 'package:owl/start_page/settings.dart';


class WordScheduler {
  WordScheduler._privateConstructor();
  static final WordScheduler instance = WordScheduler._privateConstructor();
  static final listenModeBatchSize = 5;
  static final repetitionTimesPerBatch = 3;
  static List<int> _listenModeSchedule;
  static final insertWrongAnsweredDistance = 10;
  static final  maxRepetitionsOfWrongWord = 4;
  static final  sessionMaxListenMode = 150;
  static List<dynamic> _words;
  int currentIndex = -1;
  int currentBatchStart = 0;
  int currentBatchRepetitions = 0;
  int currentIndexInBatch = 0;
  bool reachedEndInListenMode = false;
  int myDid = -1;
  bool isPracticeMode = false;
  Levenshtein d = new Levenshtein();
  var rng = new Random(new DateTime.now().millisecondsSinceEpoch);
  WordsHelper wordsHelper = WordsHelper();

  Future<String> getNextWord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if ((_words == null)
        || (myDid != prefs.getInt(ConstVariables.current_dictionary_id))
        || (isPracticeMode != Settings().practiceMod)) {
      myDid = prefs.getInt(ConstVariables.current_dictionary_id);
      isPracticeMode = Settings().practiceMod;
      await _fillWords();
    }
    _updateCurrentIndex();
    return Future.value(this._getNextWord());
  }

  void _updateCurrentIndex() {
    FLog.logThis(
      className: "WordScheduler",
      methodName: "_updateCurrentIndex",
      text: "practiceMod mode is " + isPracticeMode.toString(),
      type: LogLevel.INFO,
      dataLogType: DataLogType.DEVICE.toString(),
    );
    if (!isPracticeMode) {
      FLog.logThis(
        className: "WordScheduler",
        methodName: "_updateCurrentIndex",
        text: "current index in batch in listen mode: "
            + currentIndexInBatch.toString(),
        type: LogLevel.INFO,
        dataLogType: DataLogType.DEVICE.toString(),
      );
      if (_listenModeSchedule == null) {
        _regenerateScheduleInListenMode();
      }
      if (currentIndexInBatch == _listenModeSchedule.length) {
        currentBatchRepetitions += 1;
        currentIndexInBatch = 0;
        _listenModeSchedule.shuffle(rng);
      }
      if (currentBatchRepetitions >= repetitionTimesPerBatch) {
        _regenerateScheduleInListenMode();
      }
      currentIndex = _listenModeSchedule[currentIndexInBatch];
      currentIndexInBatch += 1;
    } else {
      currentIndex = (currentIndex + 1) % _words.length;
    }
    FLog.logThis(
      className: "WordScheduler",
      methodName: "_updateCurrentIndex",
      text: "updated current index: " + currentIndex.toString()
          + " word: " + _words[currentIndex].toString(),
      type: LogLevel.INFO,
      dataLogType: DataLogType.DEVICE.toString(),
    );
  }

  void _regenerateScheduleInListenMode() {
    // Take the next batch of the listenModeBatchSize and repeat it shuffled
    // repetitionTimesPerBatch times.
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
      for(var i = currentBatchStart; i < currentBatchEnd; i++) i];
    _listenModeSchedule.shuffle(rng);
    currentBatchRepetitions = 0;
    currentIndexInBatch = 0;

    FLog.logThis(
      className: "WordScheduler",
      methodName: "_regenerateScheduleInListenMode",
      text: "New schedule: " + (reachedEndInListenMode
          ? "Reached the end"
          :_listenModeSchedule.toString()),
      type: LogLevel.INFO,
      dataLogType: DataLogType.DEVICE.toString(),
    );
  }

  String _getNextWord() {
    return _words[currentIndex]["word"];
  }

  String getNextTranslation() {
    return _words[currentIndex]["translation"];
  }

  Future<int> updateWithAnswer(String saidWord) async {
    // https://www.supermemo.com/en/archives1990-2015/english/ol/sm2
    // q = quality of the response from 0 to 5
    // EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
    // EF < 1.3 => EF==1.3;
    // quality < 3 => repetitions := 0;
    // never called in listenMode
    assert(currentIndex != -1);
    assert(isPracticeMode);
    Map<String, dynamic> newRecord = new Map.from(_words[currentIndex]);
    int responseDistance = d.distance(
        saidWord, _words[currentIndex]["translation"]);
    int quality = 5 - ((5.0 * responseDistance)
            / _words[currentIndex]["translation"].length)
            .round();
    quality = min(max(quality, 0), 5);
    double ef = _words[currentIndex]["ef"]
        + (0.1 - (5 - quality) * (0.08 + quality * 0.02));
    ef = max(ef, 1.3);
    newRecord["ef"] = ef;
    int repetitions = _words[currentIndex]["repetitions"] + 1;
    newRecord["repetitions"] = repetitions;
    if (quality <= 3) {
      if (!newRecord.containsKey("repetitions_today")) {
        newRecord["repetitions_today"] = 0;
      }
      newRecord["repetitions_today"] += 1;
      // Don't repeat one word for a lot of times
      if (newRecord["repetitions_today"] < maxRepetitionsOfWrongWord) {
        _words.insert(
            min(currentIndex + insertWrongAnsweredDistance, _words.length),
            newRecord);
        FLog.logThis(
          className: "WordScheduler",
          methodName: "updateWithAnswer",
          text: "The words was said wrong for the "
              + newRecord["repetitions_today"].toString() + " time "
              + "and was inserted at the position "
              + min(currentIndex + insertWrongAnsweredDistance,
                  _words.length).toString(),
          type: LogLevel.INFO,
          dataLogType: DataLogType.DEVICE.toString(),
        );
      }
    }
    int nextDate = _words[currentIndex]["next_date"];
    nextDate = timeToInt(DateTime.now()) + _getInterval(
        _words[currentIndex]["repetitions"],
        _words[currentIndex]["ef"]);
    newRecord["next_date"] = nextDate;
    FLog.logThis(
      className: "WordScheduler",
      methodName: "updateWithAnswer",
      text: "Said word: " + saidWord.toString()
          + "\nTrue word: " + _words[currentIndex]["translation"].toString()
          + "\nDistance: " + responseDistance.toString()
          + "\nQuality: " + quality.toString()
          + "\nef: " + ef.toString()
          + "\nrepetitions: " + repetitions.toString()
          + "\nnext date: " + nextDate.toString(),
      type: LogLevel.INFO,
      dataLogType: DataLogType.DEVICE.toString(),
    );
    await wordsHelper.updateOneRecord(newRecord);
    return quality;
  }

  void _clear() {
    currentIndex = -1;
    currentBatchStart = 0;
    currentBatchRepetitions = 0;
    currentIndexInBatch = 0;
    reachedEndInListenMode = false;
    _listenModeSchedule = null;
  }

  Future _fillWords() async {
    _clear();
    List<Map<String, dynamic>> allWords = await wordsHelper.getCurrentWords();
    _words = new List();
    for (var j = 0; j < allWords.length; j++) {
      if (allWords[j]["next_date"] <= timeToInt(DateTime.now())) {
        _words.add(allWords[j]);
      }
    }
    FLog.logThis(
      className: "WordScheduler",
      methodName: "_fillWords",
      text: "We got the word list, length = " + _words.length.toString(),
      type: LogLevel.INFO,
      dataLogType: DataLogType.DEVICE.toString(),
    );
    if (_words.length == 0) {
      FLog.logThis(
        className: "WordScheduler",
        methodName: "_fillWords",
        text: "You have learned everything, but let's just repeat a bit :)",
        type: LogLevel.INFO,
        dataLogType: DataLogType.DEVICE.toString(),
      );
      for (var j = 0; j < allWords.length; j++) {
        _words.add(allWords[j]);
      }
    }
    _words.shuffle(rng);
    if (isPracticeMode) {
      _words = _words.sublist(0, sessionMaxListenMode);
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