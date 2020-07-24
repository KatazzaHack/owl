import 'package:flutter/material.dart';

class SettingsModel extends ChangeNotifier {

  int _speedLimit;
  int get speedLimit => _speedLimit;

  void setSpeedLimit(int newSpeed) {
    _speedLimit = newSpeed;
    notifyListeners();
  }
}