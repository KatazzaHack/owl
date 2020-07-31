import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/common_helper.dart';
import 'package:owl/dictionary/dictionaries_model.dart';
import 'package:owl/dictionary/dictionary_validator.dart';
import 'package:provider/provider.dart';

class LoadDictionaryWidget extends StatefulWidget {
  final String name;
  final SupportedLanguage originalLang, targetLang;

  const LoadDictionaryWidget({Key key, this.name, this.originalLang, this.targetLang}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LoadDictionaryWidgetState();
}

class _LoadDictionaryWidgetState extends State<LoadDictionaryWidget> {

  String _fileName = "...";
  String _path = "";
  CommonHelper ch = CommonHelper();
  DictionaryValidator dv;

  @override
  Widget build(BuildContext context) {
    dv = DictionaryValidator(context);
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Text(_fileName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16
                    ))),
            RaisedButton(
              onPressed: _pickFile,
              child: new Text("Load File"),
            )
          ],
        ),
        SizedBox(
          child: new RaisedButton(
              child: Text("Load"),
              onPressed: _onLoadPressed
          ),
          width: double.infinity
      )],
    );
  }

  _pickFile() async {
    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ["txt", "tsv", "csv"],
        allowedMimeTypes: ["text/*"]);
    _path = await FlutterDocumentPicker.openDocument(params: params);
    setState(() { _fileName = _path.split('/').last; });
  }

  void _onLoadPressed() async {
    bool isDataValid = await dv.validateChosenFile(widget.name, _path);
    if (isDataValid) {
      String content = await File(_path).readAsString();
      await ch.addNewDictionary(
          widget.name, content, widget.originalLang, widget.targetLang);
      Provider.of<DictionariesModel>(context, listen: false).updateList();
      Navigator.of(context).pop();
    }
  }
}
