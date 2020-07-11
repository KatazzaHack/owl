import 'package:owl/const_variables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:owl/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordsHelper {
  static final tableName = "Words";
  static final _instance = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await _instance.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> getCurrentWords() async {
    Database db = await _instance.database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int did = prefs.getInt(ConstVariables.current_dictionary_id);
    if (did < 0) {
      did = 0;
      prefs.setInt(ConstVariables.current_dictionary_id, did);
    }
    return await db.rawQuery('select Words.* from Words inner join WordsAndLists on (WordsAndLists.wid = Words.wid) where WordsAndLists.did=?', [did]);
  }

  Future<int> updateOneRecord(Map<String, dynamic> newRecord) async {
    Database db = await _instance.database;
    return await db.rawUpdate(
        'UPDATE Words SET wid = ?, ef = ?, next_date = ?, repetitions = ? WHERE wid = ?',
        [newRecord["wid"], newRecord["ef"], newRecord["next_date"],
          newRecord["repetitions"], newRecord["wid"]]);
  }
}