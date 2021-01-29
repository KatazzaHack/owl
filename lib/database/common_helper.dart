import 'package:sqflite/sqflite.dart';
import 'package:owl/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommonHelper {
  static final _instance = DatabaseHelper.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  CommonHelper() {
    _foo();
  }

  Future addNewDictionary(
      String name, String data, Language l_o, Language l_t) async {
    Database db = await _instance.database;
    int count = Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM Dictionaries where name=?', [name]));
    if (count > 0) {
      return;
    }
    List wordsList = data.split("\n");
    int id = await _instance.getCount(db, "Words");
    int did = await _instance.getCount(db, "Dictionaries");
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
  }

  Future _foo() async {
    Database db = await _instance.database;
    users
        .add({'timestamp': DateTime.now().toString()})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
