import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/dictionary_helper.dart';
import 'package:owl/database/common_helper.dart';
import 'package:owl/dictionary/load_dictionary_widget.dart';
import 'package:owl/dictionary/download_dictionary_widget.dart';
import 'package:owl/utils.dart';
import 'dictionary_selection_page.dart';

class DictionaryAddPage extends StatefulWidget {
  final AddDictionaryMethod addDictionaryMethod;

  const DictionaryAddPage({Key key, this.addDictionaryMethod})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DictionaryAddPageState();
}

class _DictionaryAddPageState extends State<DictionaryAddPage> {
  final TextEditingController _nameFilter = new TextEditingController();

  String _name = "";
  Language _originalLang;
  Language _targetLang;
  DictionariesHelper dh = DictionariesHelper();
  CommonHelper ch = CommonHelper();

  _DictionaryAddPageState() {
    _nameFilter.addListener(_nameListen);
    _originalLang = ConstVariables.reverse_human_languages["German"];
    _targetLang = ConstVariables.reverse_human_languages["Russian"];
  }

  void _nameListen() {
    if (_nameFilter.text.isEmpty) {
      setState(() {
        _name = "";
      });
    } else {
      setState(() {
        _name = _nameFilter.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text("Add New Dictionary"),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildInfo(),
            _buildNameField(),
            _buildLangSelectors(),
            _buildAddDictionaryWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _buildLangSelectors() {
    return new Container(
      child: Column(
        children: <Widget>[
          ListTile(
              title: Text("Original language"),
              trailing: DropdownButton<Language>(
                value: _originalLang,
                onChanged: (Language newValue) {
                  setState(() {
                    print(newValue);
                    _originalLang = newValue;
                  });
                },
                items: ConstVariables.all_languages
                    .map<DropdownMenuItem<Language>>((Language value) {
                  return DropdownMenuItem<Language>(
                    value: value,
                    child: Text(value.humanLanguage),
                  );
                }).toList(),
              )),
          ListTile(
              title: Text("Translation Language"),
              trailing: DropdownButton<Language>(
                value: _targetLang,
                onChanged: (Language newValue) {
                  setState(() {
                    print(newValue);
                    _targetLang = newValue;
                  });
                },
                items: ConstVariables.all_languages
                    .map<DropdownMenuItem<Language>>((Language value) {
                  return DropdownMenuItem<Language>(
                    value: value,
                    child: Text(value.humanLanguage),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      child: TextField(
        controller: _nameFilter,
        decoration: InputDecoration(labelText: 'Dictionary name'),
      ),
    );
  }

  Widget _buildAddDictionaryWidgets() {
    return Container(child: (() {
      if (widget.addDictionaryMethod == AddDictionaryMethod.load_from_file) {
        return LoadDictionaryWidget(
            name: _name, originalLang: _originalLang, targetLang: _targetLang);
      }
      return DownloadDictionaryWidget(
          name: _name, originalLang: _originalLang, targetLang: _targetLang);
    })());
  }

  Widget _buildInfo() {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "How to add a deck?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 32,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
              text: "To add a deck please create a text file. This file "
                  "should consist of lines, where each line is a text splitted "
                  "by a tab symbol. For example, if you are creating a deck "
                  "for learning languages, then put the word you would like to "
                  "learn before tab and its translation after tab. ",
              style: TextStyle(color: Colors.black38, fontSize: 16),
            ),
            TextSpan(
              text: "Learn more...",
              style: TextStyle(color: Colors.blue, fontSize: 16),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launchURL(ConstVariables.FAQURL);
                },
            ),
          ]))
        ],
      ),
    );
  }
}
