import 'package:sqflite/sqflite.dart';
import 'package:owl/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

class DictionariesHelper {
  static final tableName = "Dictionaries";
  static final _instance = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await _instance.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> queryWithActiveFlag() async {
    List<Map<String, dynamic>> result = await queryAllRows();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentDictionaryId =
        prefs.getInt(ConstVariables.current_dictionary_id);
    await _setLanguages(currentDictionaryId);
    List<Map<String, dynamic>> newResult =
        List.generate(result.length, (index) {
      Map<String, dynamic> map = new Map<String, dynamic>();
      map['active'] = currentDictionaryId == result[index]['did'];
      map['did'] = result[index]['did'];
      map['name'] = result[index]['name'];
      return map;
    });
    return newResult;
  }

  Future _setLanguages(int currentDictionaryId) async {
    Database db = await _instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * from $tableName where did=?', [currentDictionaryId]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(ConstVariables.original_language, result[0]['l_original']);
    prefs.setString(
        ConstVariables.translate_language, result[0]['l_translation']);
  }

  Future<bool> checkIfDictionaryExists(String name) async {
    Database db = await _instance.database;
    int count = Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM $tableName where name=?', [name]));
    return count > 0;
  }
}
