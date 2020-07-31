import 'package:flutter/material.dart';
import 'package:owl/database/dictionary_helper.dart';

class DictionaryValidator {
  BuildContext _context;
  DictionariesHelper dh = DictionariesHelper();

  DictionaryValidator(BuildContext context) {
    _context = context;
  }

  Future<bool> validateChosenFile(String name, String path) async {
    bool _correctNameFormat = await _validateName(name);
    String title = "", errorText, actionText;
    if (!_correctNameFormat) {
      title = 'Dictionary name';
      errorText = 'Name is empty or you already have a dictionary with this '
          'name. Please change it!';
      actionText = 'Will change!';
    }

    if (path.isEmpty) {
      title = 'File not chosen';
      errorText = 'No dictionary chosen, please chose a dictionary to load by pressing Load File button.';
      actionText = 'Will choose!';
    }

    if (title.isNotEmpty) {
      showAlertDialog(title, errorText, actionText);
      return false;
    }
    return true;
  }

  Future<bool> validateURL(String name, String url) async {
    bool _correctNameFormat = await _validateName(name);
    String title = "", errorText, actionText;
    if (!_correctNameFormat) {
      title = 'Dictionary name';
      errorText = 'You already have a dictionary with this name. Please change it!';
      actionText = 'Will change!';
    }

    if (!Uri
        .parse(url)
        .isAbsolute) {
      title = 'URL is wrong format';
      errorText = 'Please check your the format of the URL provided.';
      actionText = 'Ok';
    }

    if (title.isNotEmpty) {
      showAlertDialog(title, errorText, actionText);
      return false;
    }
    return true;
  }

  void showAlertDialog(String title, String errorText, actionText) async {
    await showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _alertWindow(title, errorText, actionText);
      },
    );
  }

  Future<bool> _validateName(String name) async {
    if (name.isEmpty)
      return false;
    bool _exists = await dh.checkIfDictionaryExists(name);
    return !_exists;
  }

  Widget _alertWindow(String title, String text, String actionText) {
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
          child: Text(actionText),
          onPressed: () {
            Navigator.of(_context).pop();
          },
        ),
      ],
    );
  }
}