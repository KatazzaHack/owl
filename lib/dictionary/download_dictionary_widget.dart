import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/dictionary_helper.dart';
import 'package:http/http.dart' as http;
import 'package:owl/database/common_helper.dart';
import 'package:owl/dictionary/dictionaries_model.dart';
import 'package:owl/dictionary/dictionary_validator.dart';
import 'package:provider/provider.dart';

class DownloadDictionaryWidget extends StatefulWidget {
  final String name;
  final Language originalLang, targetLang;

  const DownloadDictionaryWidget({Key key, this.name, this.originalLang, this.targetLang}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DownloadDictionaryWidgetState();
}

class _DownloadDictionaryWidgetState extends State<DownloadDictionaryWidget> {
  final TextEditingController _urlFilter = new TextEditingController();

  String _url = "";
  DictionariesHelper dh = DictionariesHelper();
  CommonHelper ch = CommonHelper();
  DictionaryValidator dv;

  _DownloadDictionaryWidgetState() {
    _urlFilter.addListener(_urlListen);
  }

  void _urlListen() {
    if (_urlFilter.text.isEmpty) {
      _url = "";
    } else {
      _url = _urlFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    dv = DictionaryValidator(context);
    return Column(
      children: <Widget>[
        TextField(
          controller: _urlFilter,
          decoration: new InputDecoration(labelText: 'Downloadable deck URL'),
        ),
        SizedBox(
          child: RaisedButton(
            child: new Text('Download and Load'),
            onPressed: _downloadPressed,
          ),
          width: double.infinity
        )
      ],
    );
  }

  void _downloadPressed() async {
    bool isDataValid = await dv.validateURL(widget.name, _url);
    if (isDataValid) {
      final response = await http.get(_url);
      if (response.statusCode != 200) {
        return dv.showAlertDialog('Url', response.reasonPhrase, 'Ok');
      } else {
        await ch.addNewDictionary(widget.name, response.body, widget.originalLang, widget.targetLang);
      }
      Provider.of<DictionariesModel>(context, listen: false).updateList();
      Navigator.of(context).pop();
    }
  }
}
