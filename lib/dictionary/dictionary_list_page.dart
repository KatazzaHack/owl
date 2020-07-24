import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/dictionary/dictionaries_model.dart';
import 'package:provider/provider.dart';

class DictionaryListPage extends StatefulWidget {
  DictionaryListPage({Key key}) : super(key: key);

  @override
  _ListSearchState createState() => _ListSearchState();
}

class _ListSearchState extends State<DictionaryListPage> {

  int _globalId = 0;

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
      _globalId = dictionaries.globalId;
      return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(children: <Widget>[
            Expanded(
                child: ListView(
              children: dictionaries.dictionariesList?.map((data) {
                return radioListTile(data["did"], data["name"]);
              })?.toList() ?? [],
            ))
          ]));
    });
  }

  Widget radioListTile(int id, String text) {
    return RadioListTile<int>(
      title: Text(text),
      value: id,
      groupValue: _globalId,
      onChanged: (int value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(ConstVariables.current_dictionary_id, id);
        setState(() { _globalId = value; });
        Provider.of<DictionariesModel>(context, listen: false).updateList();
      },
    );
  }
}
