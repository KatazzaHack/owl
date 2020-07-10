import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _urlFilter = new TextEditingController();
  final TextEditingController _nameFilter = new TextEditingController();
  String _name = "";
  String _url = "";

  _LoginPageState() {
    _urlFilter.addListener(_urlListen);
    _nameFilter.addListener(_nameListen);
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
            _buildButtons(),
          ],
        ),
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
              decoration: new InputDecoration(
                  labelText: 'Name'
              ),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _urlFilter,
              decoration: new InputDecoration(
                  labelText: 'Url'
              ),
              obscureText: true,
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

  void _uploadPressed() {
    print('The user wants to login with $_name and $_url');
  }

}