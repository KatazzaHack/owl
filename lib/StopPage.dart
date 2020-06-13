import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                  child: RaisedButton(
                    shape: CircleBorder(),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("STOP", style: TextStyle(fontSize: 40)),
                  ),
                )));
  }
}
