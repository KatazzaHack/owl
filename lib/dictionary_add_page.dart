import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:owl/database/dictionary_helper.dart';
import 'package:owl/database/common_helper.dart';
import 'package:owl/load_dictionary_widget.dart';
import 'package:owl/download_dictionary_widget.dart';

import 'dictionary_selection_page.dart';

class DictionaryAddPage extends StatefulWidget {
  final AddDictionaryMethod addDictionaryMethod;

  const DictionaryAddPage({Key key, this.addDictionaryMethod}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DictionaryAddPageState();
}

class _DictionaryAddPageState extends State<DictionaryAddPage> {
  final TextEditingController _nameFilter = new TextEditingController();

  String _name = "";
  SupportedLanguage _originalLang;
  SupportedLanguage _targetLang;
  DictionariesHelper dh = DictionariesHelper();
  CommonHelper ch = CommonHelper();

  _DictionaryAddPageState() {
    _nameFilter.addListener(_nameListen);
    _originalLang = SupportedLanguage.German;
    _targetLang = SupportedLanguage.Russian;
  }

  void _nameListen() {
    if (_nameFilter.text.isEmpty) {
      setState(() { _name = ""; });
    } else {
      setState(() { _name = _nameFilter.text; });
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
              trailing: DropdownButton<SupportedLanguage>(
                value: _originalLang,
                onChanged: (SupportedLanguage newValue) {
                  setState(() {
                    print(newValue);
                    _originalLang = newValue;
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
                value: _targetLang,
                onChanged: (SupportedLanguage newValue) {
                  setState(() {
                    print(newValue);
                    _targetLang = newValue;
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
      title: new Text("Add New Dictionary"),
      centerTitle: true,
    );
  }

  Widget _buildNameField() {
    return new Container(
      child: new TextField(
        controller: _nameFilter,
        decoration: new InputDecoration(labelText: 'Dictionary name'),
      ),
    );
  }

  Widget _buildAddDictionaryWidgets() {
    return new Container(
      child: (() {
        if (widget.addDictionaryMethod ==
            AddDictionaryMethod.load_from_file) {
          return LoadDictionaryWidget(
              name: _name,
              originalLang: _originalLang,
              targetLang: _targetLang);
        }
        return DownloadDictionaryWidget(
            name: _name,
            originalLang: _originalLang,
            targetLang: _targetLang);
      })()
    );
  }
}
