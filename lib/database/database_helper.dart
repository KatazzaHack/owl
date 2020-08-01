import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/utils.dart';

class DatabaseHelper {
  static final _databaseVersion = 41;
  static final _databaseName = "owl_release_database_2.db";

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Dictionaries ( did INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, l_original TEXT, l_translation TEXT)");
    await db.execute("CREATE TABLE Words ("
        "wid INTEGER PRIMARY KEY,"
        "word TEXT NOT NULL,"
        "translation TEXT,"
        "ef REAL,"
        "repetitions INTEGER,"
        "next_date INTEGER)");
    await db.execute(
        "CREATE TABLE WordsAndLists (did INTEGER, wid INTEGER, PRIMARY KEY (did, wid))");
    await _addNewDictionary(
        db,
        "DE_RU_A1",
        ConstVariables.reverse_languages[SupportedLanguage.German],
        ConstVariables.reverse_languages[SupportedLanguage.Russian]);
    await _addNewDictionary(
        db,
        "DE_RU_A1-B1",
        ConstVariables.reverse_languages[SupportedLanguage.German],
        ConstVariables.reverse_languages[SupportedLanguage.Russian]);
    await _addNewDictionary(
        db,
        "DE_RU_A2",
        ConstVariables.reverse_languages[SupportedLanguage.German],
        ConstVariables.reverse_languages[SupportedLanguage.Russian]);
    await _addNewDictionary(
        db,
        "EN_DE_A2",
        ConstVariables.reverse_languages[SupportedLanguage.English],
        ConstVariables.reverse_languages[SupportedLanguage.German]);
    await _addNewDictionary(
        db,
        "EN_RU_A2",
        ConstVariables.reverse_languages[SupportedLanguage.English],
        ConstVariables.reverse_languages[SupportedLanguage.Russian]);
    await _addNewDictionary(
        db,
        "EN_RU_B2",
        ConstVariables.reverse_languages[SupportedLanguage.English],
        ConstVariables.reverse_languages[SupportedLanguage.Russian]);
    await _addNewDictionary(
        db,
        "EN_RU_C1",
        ConstVariables.reverse_languages[SupportedLanguage.English],
        ConstVariables.reverse_languages[SupportedLanguage.Russian]);
  }

  Future<int> getCount(db, String dbName) async {
    var x = await db.rawQuery('SELECT COUNT (*) from $dbName');
    int count = Sqflite.firstIntValue(x);
    return count;
  }

  Future _addNewDictionary(
      Database db, String name, Language l_o, Language l_t) async {
    String data = await rootBundle.loadString('assets/' + name + '.txt');
    int count = Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM Dictionaries where name=?', [name]));
    if (count > 0) {
      return;
    }
    List wordsList = data.split("\n");
    int id = await getCount(db, "Words");
    int did = await getCount(db, "Dictionaries");
    did = did + 1;
    Batch batch = db.batch();
    batch.execute("begin");
    batch.insert("Dictionaries", {
      "name": name,
      "did": did,
      "l_original": l_o.humanLanguage,
      "l_translation": l_t.humanLanguage,
    });

    wordsList.forEach((word) {
      List wordTranslation = word.split("\t");
      id = id + 1;
      batch.insert("Words", {
        "word": wordTranslation[0],
        "wid": id,
        "translation": wordTranslation[1].split(",")[0],
        "ef": 2.5,
        "next_date": timeToInt(DateTime.now()),
        "repetitions": 0,
      });
      batch.insert("WordsAndLists", {"did": did, "wid": id});
    });
    batch.execute("end");
    await batch.commit(noResult: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(ConstVariables.current_dictionary_id, did);
    prefs.setString(ConstVariables.original_language, l_o.humanLanguage);
    prefs.setString(ConstVariables.translate_language, l_t.humanLanguage);
  }
}
