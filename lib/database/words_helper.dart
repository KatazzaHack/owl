import 'package:sqflite/sqflite.dart';
import 'package:owl/database/database_helper.dart';

class WordsHelper {
  static final tableName = "Words";
  static final _instance = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await _instance.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> getWordsFromDictionary() async {
    }
}
