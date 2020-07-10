import 'package:sqflite/sqflite.dart';
import 'package:owl/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

class CommonHelper {
  static final _instance = DatabaseHelper.instance;

  Future addNewDictionary(String name, String data) async {
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
    batch.insert("Dictionaries", {"name": name, "did": did});
    wordsList.forEach((word) {
      List wordTranslation = word.split("\t");
      id = id + 1;
      batch.insert("Words", {
        "word": wordTranslation[0],
        "wid": id,
        "translation": wordTranslation[1].split(",")[0],
        "ef": 2.5,
        "next_date": _instance.timeToInt(DateTime.now()),
        "repetitions": 0,
      });
      batch.insert("WordsAndLists", {"did": did, "wid": id});
    });
    batch.execute("end");
    await batch.commit(noResult: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(ConstVariables.current_dictionary_id, did);
  }
}