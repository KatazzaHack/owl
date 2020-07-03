import 'package:flutter/material.dart';
import 'package:owl/database/dictionary_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/const_variables.dart';

class DictionaryListPage extends StatefulWidget {
  ListSearchState createState() => ListSearchState();
}

class ListSearchState extends State<DictionaryListPage> {
  DictionariesHelper _helper = DictionariesHelper();

  // Copy Main List into New List.
  Future<List<Map<String, dynamic>>> newDataList;

  @override
  void initState() {
    super.initState();
    newDataList = _helper.queryWithActiveFlag();
  }

  onItemChanged(String value) async {
    setState(() {
      newDataList = _helper.queryWithActiveFlag();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: newDataList,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                    children: <Widget>[
                      Expanded(
                          child:
                          ListView(
                            children: snapshot.data.map((data) {
                              return ListTile(
                                  leading: checkbox(
                                      data["did"], data["active"]),
                                  title: Text(data["name"]));
                            }).toList(),
                          )
                      )
                    ]
                )
            );
          } else {
            return CircularProgressIndicator();
          }
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
        setState(() {
          newDataList = _helper.queryWithActiveFlag();
        });
      },
    );
  }
}
