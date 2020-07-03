import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owl/dictionary_list_page.dart';

class DictionarySelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select dictionary"),
      ),
      body: Column(
        children: <Widget>[
          DictionaryListPage()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        tooltip: "Add new dictionary",
        child: Icon(Icons.add_box),
      ),
    );
  }
}