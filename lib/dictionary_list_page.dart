import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/dictionaries_model.dart';
import 'package:provider/provider.dart';

class DictionaryListPage extends StatefulWidget {
  DictionaryListPage({Key key}) : super(key: key);

  @override
  _ListSearchState createState() => _ListSearchState();
}

class _ListSearchState extends State<DictionaryListPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<DictionariesModel>(context, listen: false).updateList();
  }

  onItemChanged(String value) async {
    Provider.of<DictionariesModel>(context, listen: false).updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DictionariesModel>(builder: (context, dictionaries, child) {
      assert(dictionaries != null);
      return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(children: <Widget>[
            Expanded(
                child: ListView(
              children: dictionaries.dictionariesList.map((data) {
                return ListTile(
                    leading: checkbox(data["did"], data["active"]),
                    title: Text(data["name"]));
              }).toList(),
            ))
          ]));
    });
  }

  Widget checkbox(int id, bool active) {
    return Checkbox(
      value: active,
      onChanged: (bool value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!value) {
          prefs.setInt(ConstVariables.current_dictionary_id, -1);
        } else {
          prefs.setInt(ConstVariables.current_dictionary_id, id);
        }
        Provider.of<DictionariesModel>(context, listen: false).updateList();
      },
    );
  }
}
