import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseHelper {
  static final _databaseName = "owl_database4.db";
  static final _databaseVersion = 4;

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
        "CREATE TABLE Lists ( lid INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE)");
    await db.execute(
        "CREATE TABLE Words ( wid INTEGER PRIMARY KEY, word TEXT NOT NULL UNIQUE)");
    await db.execute(
        "CREATE TABLE WordsAndLists (lid INTEGER, wid INTEGER, PRIMARY KEY (lid, wid))");
    await _addDefault(db);
  }

  Future _addDefault(db) async {
    String words = await rootBundle.loadString('assets/words.txt');
    print(words);
    List wordsList = words.split("\n");
    Batch batch = db.batch();
    batch.insert("Lists", {"name": "default", "lid": 1});
    int id = 0;
    wordsList.forEach((word) {
      id = id + 1;
      batch.insert("Words", {"word": word, "wid": id});
      batch.insert("WordsAndLists", {"lid": 1, "wid": id});
      print(word);
    });
    await batch.commit(noResult: true);
    print("Filled Database");
  }
}
