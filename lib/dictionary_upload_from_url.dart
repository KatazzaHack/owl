import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/dictionary_helper.dart';
import 'package:http/http.dart' as http;
import 'package:owl/database/common_helper.dart';

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
              title: Text("Original Language"),
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
      title: new Text("Upload New Dictionary"),
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
            child: new Text('Upload'),
            onPressed: _uploadPressed,
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

  Future<void> _uploadPressed() async {
    bool _correct_name_format = await _validateName(_name);
    if (!_correct_name_format) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Dictionary name'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'You have a dictionary with that name. Please change it!'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Will change!'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    if (!Uri.parse(_url).isAbsolute) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Url'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please check your url'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    final response = await http.get(_url);
    if (response.statusCode != 200) {
      return AlertDialog(
        title: Text('Url'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(response.reasonPhrase),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      await ch.addNewDictionary(_name, response.body, _l_o, _l_t);
    }
    Navigator.of(context).pop();
  }
}
