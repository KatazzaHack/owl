import 'package:flutter/material.dart';

class TrainingModModel extends ChangeNotifier {
  bool _state = false;

  int get state => _state ? 1 : 0;

  void setState(int state) {
    assert((state == 0) || (state == 1));
    _state = state == 1;
    notifyListeners();
  }
}