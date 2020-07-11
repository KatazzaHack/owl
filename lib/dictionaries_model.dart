import 'package:flutter/material.dart';
import 'package:owl/database/dictionary_helper.dart';

class DictionariesModel extends ChangeNotifier {
  List<Map<String, dynamic>> _dictionariesList;
  DictionariesHelper _helper = DictionariesHelper();

  List<Map<String, dynamic>> get dictionariesList => _dictionariesList;

  void updateList() async {
    _dictionariesList = await _helper.queryWithActiveFlag();
    notifyListeners();
  }
}