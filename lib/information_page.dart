import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text("Information"),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ExpansionTile(
            title: Text("1"),
            children: <Widget>[
              Text("lol1")
            ],
          ),
          ExpansionTile(
            title: Text("1"),
            children: <Widget>[
              Text("lol1")
            ],
          )
        ],
      )
    );
  }

  List<Map<String, String>> question_to_answer = [
    {"q": "1", "a": "2"},
    {"q": "3", "a": "4"},
  ];
}


