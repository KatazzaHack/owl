import 'package:flutter/material.dart';

class StopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: ClipOval(
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Stop"),
              ),
            )));
  }
}
