import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:owl/Speaker.dart';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {

  final Speaker _speaker = Speaker();

  final StreamController<int> _streamController = StreamController<int>(
      onCancel: () {
        print("Cancel Handler");
      }
  );

  @override
  void initState() {
    _streamController.addStream((() async* {
      await Future<void>.delayed(Duration(seconds: 1));
      for (var i = 0;; i++) {
        await _speaker.say("dog");
        yield i;
        await Future<void>.delayed(Duration(seconds: 1));
      }
    })());
    super.initState();
  }

  @override
  void dispose(){
    print("here");
    _streamController.close();
    super.dispose();
  }

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
                      stream: _streamController.stream,
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
