import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:owl/start_page/settings.dart';

class TrainingModModel extends ChangeNotifier {
  int get stateIdx => SettingsOWL().practiceMod ? 1 : 0;

  void setState(int state) {
    assert((state == 0) || (state == 1));
    SettingsOWL().practiceMod = (state == 1);
    FLog.logThis(
      className: "TrainingModModel",
      methodName: "setState",
      text: "practice mode is: " + SettingsOWL().practiceMod.toString(),
      type: LogLevel.INFO,
      dataLogType: DataLogType.DEVICE.toString(),
    );
    notifyListeners();
  }
}