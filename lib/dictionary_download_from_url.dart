import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/dictionary_helper.dart';
import 'package:http/http.dart' as http;
import 'package:owl/database/common_helper.dart';
import 'package:owl/dictionaries_model.dart';
import 'package:provider/provider.dart';

class DictionaryFromUrlPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DictionaryFromUrlPageState();
}

class _DictionaryFromUrlPageState extends State<DictionaryFromUrlPage> {
  final TextEditingController _urlFilter = new TextEditingController();
  final TextEditingController _nameFilter = new TextEditingController();

  String _name = "";
  String _url = "";
  SupportedLanguage _l_o;
  SupportedLanguage _l_t;
  DictionariesHelper dh = DictionariesHelper();
  CommonHelper ch = CommonHelper();

  _DictionaryFromUrlPageState() {
    _urlFilter.addListener(_urlListen);
    _nameFilter.addListener(_nameListen);
    _l_o = SupportedLanguage.German;
    _l_t = SupportedLanguage.Russian;
  }

  void _urlListen() {
    if (_urlFilter.text.isEmpty) {
      _url = "";
    } else {
      _url = _urlFilter.text;
    }
  }

  void _nameListen() {
    if (_nameFilter.text.isEmpty) {
      _name = "";
    } else {
      _name = _nameFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(context),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            _buildTextFields(),
            _buildLanguages(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguages() {
    return new Container(
      child: Column(
        children: <Widget>[
          ListTile(
              title: Text("Original language"),
              trailing: DropdownButton<SupportedLanguage>(
                value: _l_o,
                onChanged: (SupportedLanguage newValue) {
                  setState(() {
                    print(newValue);
                    _l_o = newValue;
                  });
                },
                items: ConstVariables.all_languages
                    .map<DropdownMenuItem<SupportedLanguage>>(
                        (SupportedLanguage value) {
                  return DropdownMenuItem<SupportedLanguage>(
                    value: value,
                    child: Text(ConstVariables.human_languages[value]),
                  );
                }).toList(),
              )),
          ListTile(
              title: Text("Translation Language"),
              trailing: DropdownButton<SupportedLanguage>(
                value: _l_t,
                onChanged: (SupportedLanguage newValue) {
                  setState(() {
                    print(newValue);
                    _l_t = newValue;
                  });
                },
                items: ConstVariables.all_languages
                    .map<DropdownMenuItem<SupportedLanguage>>(
                        (SupportedLanguage value) {
                  return DropdownMenuItem<SupportedLanguage>(
                    value: value,
                    child: Text(ConstVariables.human_languages[value]),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Download New Dictionary"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _nameFilter,
              decoration: new InputDecoration(labelText: 'Dictionary name'),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _urlFilter,
              decoration: new InputDecoration(labelText: 'Url'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new RaisedButton(
            child: new Text('download'),
            onPressed: _downloadPressed,
          ),
        ],
      ),
    );
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  Future<bool> _validateName(String name) async {
    bool _exists = await dh.checkIfDictionaryExists(name);
    return !_exists;
  }

  Widget _alertWindow(String title, String text, String action_text) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(text),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(action_text),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> _downloadPressed() async {
    bool _correct_name_format = await _validateName(_name);
    if (!_correct_name_format) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return _alertWindow(
              'Dictionary name',
              'You have a dictionary with that name. Please change it!',
              'Will change!');
        },
      );
    }
    if (!Uri.parse(_url).isAbsolute) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return _alertWindow('Url', 'Please check your url', 'Ok');
        },
      );
    }
    final response = await http.get(_url);
    if (response.statusCode != 200) {
      return _alertWindow('Url', response.reasonPhrase, 'Ok');
    } else {
      await ch.addNewDictionary(_name, response.body, _l_o, _l_t);
    }
    Provider.of<DictionariesModel>(context, listen: false).updateList();
    Navigator.of(context).pop();
  }
}
