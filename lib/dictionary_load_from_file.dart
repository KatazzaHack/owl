import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/common_helper.dart';
import 'package:owl/dictionaries_model.dart';
import 'package:provider/provider.dart';

class DictionaryFromFilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DictionaryFromUrlPageState();
}

class _DictionaryFromUrlPageState extends State<DictionaryFromFilePage> {
  CommonHelper ch = CommonHelper();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(context),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Container(
            child: new RaisedButton(
          onPressed: _pickFile,
          child: new Text("Load File"),
        )),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Add New Dictionary"),
      centerTitle: true,
    );
  }

  _pickFile() async {
    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ["txt", "tsv", "csv"],
        allowedMimeTypes: ["text/*"]);
    final path = await FlutterDocumentPicker.openDocument(params: params);
    print(path);
    String content = await File(path).readAsString();
//    Stream<List<int>> inputStream = File(path).openRead();
//    inputStream.transform(utf8.decoder).listen(
//        (x) { print(x); },
//        onDone: () { print('File is now closed.'); },
//        onError: (e) { print(e.toString()); }
//    );
//    print(contents);
    print("Content is ready, content length = " + content.length.toString());
//    await ch.addNewDictionary("Lol", , SupportedLanguage.German, SupportedLanguage.Russian);
//    Provider.of<DictionariesModel>(context, listen: false).updateList();
//    Navigator.of(context).pop();
  }
}
