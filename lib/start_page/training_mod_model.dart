import 'package:flutter/material.dart';
import 'package:owl/start_page/settings.dart';

class TrainingModModel extends ChangeNotifier {
  int get stateIdx => Settings().listen ? 1 : 0;

  void setState(int state) {
    assert((state == 0) || (state == 1));
    Settings().listen = state == 1;
    notifyListeners();
  }
}