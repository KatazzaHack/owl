import 'package:flutter/material.dart';
import 'package:owl/settings/settings.dart';
import 'package:f_logs/f_logs.dart';

class TrainingModModel extends ChangeNotifier {
  int get stateIdx => Settings().practiceMod ? 1 : 0;

  void setState(int state) {
    assert((state == 0) || (state == 1));
    Settings().practiceMod = (state == 1);
    FLog.logThis(
      className: "TrainingModModel",
      methodName: "setState",
      text: "practice mode is: " + Settings().practiceMod.toString(),
      type: LogLevel.INFO,
      dataLogType: DataLogType.DEVICE.toString(),
    );
    notifyListeners();
  }
}