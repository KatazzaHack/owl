import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

class SettingsModel extends ChangeNotifier {

  int _speedLimit = 1;
  int get speedLimit => _speedLimit;

  void setSpeedLimit(int newSpeed) {
    _speedLimit = newSpeed;
    _updateSpeedInPreferences(newSpeed);
    notifyListeners();
  }

  void perhapsInit() async {
    int iValue = await _getSpeed();
    _speedLimit = iValue;
    notifyListeners();
  }
}

void _updateSpeedInPreferences(int newSpeed) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(ConstVariables.speed_id, newSpeed);
}

Future<int> _getSpeed() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(ConstVariables.speed_id)) {
    prefs.setInt(ConstVariables.speed_id, 2);
    return 2;
  } else {
    return prefs.getInt(ConstVariables.speed_id);
  }
}