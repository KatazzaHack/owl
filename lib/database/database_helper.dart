import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../const_variables.dart';

class DatabaseHelper {
  static final _databaseName = "owl_database228.db";
  static final _databaseVersion = 228;

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
        "CREATE TABLE Dictionaries ( did INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE)");
    await db.execute(
        "CREATE TABLE Words ("
            "wid INTEGER PRIMARY KEY,"
            "word TEXT NOT NULL UNIQUE,"
            "translation TEXT,"
            "ef REAL,"
            "repetitions INTEGER,"
            "next_date INTEGER)");
    await db.execute(
        "CREATE TABLE WordsAndLists (did INTEGER, wid INTEGER, PRIMARY KEY (did, wid))");
    // await _addDefault(db);
    await _addGerman(db);
  }

  Future _addDefault(db) async {
    String words = await rootBundle.loadString('assets/words.txt');
    List wordsList = words.split("\n");
    Batch batch = db.batch();
    batch.execute("begin");
    batch.insert("Dictionaries", {"name": "default", "did": 1});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(ConstVariables.current_dictionary_id, 1);
    int id = 0;
    wordsList.forEach((word) {
      id = id + 1;
      batch.insert("Words", {"word": word, "wid": id});
      batch.insert("WordsAndLists", {"did": 1, "wid": id});
    });
    batch.execute("end");
    await batch.commit(noResult: true);
    Batch batch2 = db.batch();
    batch2.execute("begin");
    batch2.insert("Dictionaries", {"name": "football", "did": 2});
    id = id + 1;
    batch2.insert("Words", {"word": "hulikau", "wid": id});
    batch2.insert("WordsAndLists", {"did": 2, "wid": id});
    batch2.execute("end");
    await batch2.commit(noResult: true);
  }

  Future _addGerman(db) async {
    String words = await rootBundle.loadString('assets/deckb1.txt');
    List wordsList = words.split("\n");
    Batch batch = db.batch();

    batch.execute("begin");
    batch.insert("Lists", {"name": "deutsch", "did": 2});
    int id = 0;
    wordsList.forEach((word) {
      List wordTranslation = word.split("\t");
      id = id + 1;
      batch.insert("Words",
          {
            "word": wordTranslation[0], "wid": id,
            "translation": wordTranslation[1].split(",")[0],
            "ef": 2.5,
            "next_date": timeToInt(DateTime.now()),
            "repetitions": 0,
          });
      batch.insert("WordsAndLists", {"did": 2, "wid": id});
    });
    batch.execute("end");
    await batch.commit(noResult: true);
  }

  int timeToInt(DateTime dateTime) {
    return (dateTime.millisecondsSinceEpoch / (1000000 * 60 * 60 * 24)).round();
  }
}


