import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owl/dictionary_list_page.dart';
import 'package:owl/dictionary_download_from_url.dart';
import 'package:owl/dictionary_load_from_file.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DictionaryFromFilePage()),
          );
        },
        tooltip: "Add new dictionary",
        child: Icon(Icons.add_box),
      ),
    );
  }
}