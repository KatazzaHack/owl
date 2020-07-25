import 'package:flutter/material.dart';
import 'package:owl/database/dictionary_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

class DictionariesModel extends ChangeNotifier {
  List<Map<String, dynamic>> _dictionariesList;
  DictionariesHelper _helper = DictionariesHelper();
  int _globalId;

  List<Map<String, dynamic>> get dictionariesList => _dictionariesList;

  int get globalId => _globalId;

  void updateList() async {
    _dictionariesList = await _helper.queryWithActiveFlag();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _globalId = prefs.getInt(ConstVariables.current_dictionary_id);
    notifyListeners();
  }
}