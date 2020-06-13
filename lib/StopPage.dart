import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:async';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {

  static Stream<int> _bids = (() async* {
    await Future<void>.delayed(Duration(seconds: 3));
    for (var i = 0;; i++) {
      yield i;
      await Future<void>.delayed(Duration(seconds: 3));
    }
  })();

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
                  child: new StreamBuilder<int>(
                      stream: _bids,
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.hasData) {
                          return Text("STOP ${snapshot.data}",
                              style: TextStyle(fontSize: 40));
                        } else {
                          return CircularProgressIndicator();
                        }
                      })),
            )));
  }

}
