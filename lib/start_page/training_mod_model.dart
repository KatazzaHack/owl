import 'package:flutter/material.dart';

class TrainingModModel extends ChangeNotifier {
  bool _listen = false;

  int get stateIdx => _listen ? 1 : 0;
  bool get listen => _listen;

  void setState(int state) {
    assert((state == 0) || (state == 1));
    _listen = state == 1;
    notifyListeners();
  }
}