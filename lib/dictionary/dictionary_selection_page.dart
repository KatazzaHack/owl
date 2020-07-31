import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owl/dictionary/dictionary_add_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:owl/dictionary/dictionary_list_page.dart';

enum AddDictionaryMethod { load_from_file, download_from_url }

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
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        tooltip: "Add new dictionary",
        children: [
          SpeedDialChild(
            child: Icon(Icons.file_download),
            label: "Download from URL",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DictionaryAddPage(
                  addDictionaryMethod: AddDictionaryMethod.download_from_url
                )),
              );
            }
          ),
          SpeedDialChild(
            child: Icon(Icons.insert_drive_file),
            label: "Load from file",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DictionaryAddPage(
                  addDictionaryMethod: AddDictionaryMethod.load_from_file
                )),
              );
            }
          )
        ],
      )
    );
  }
}