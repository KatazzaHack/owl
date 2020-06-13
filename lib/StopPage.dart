import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owl/tts.dart';

import 'package:speech_to_text/speech_to_text.dart';

import 'dart:async';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {

  final SpeechToText _speech = SpeechToText();

  final StreamController<int> _streamController = StreamController<int>(
      onCancel: () {
        print("Cancel Handler");
      }
  );

  @override
  void initState() async {
    await _speech.initialize();
    String dog = "dog";
    _streamController.addStream((() async* {
      await Future<void>.delayed(Duration(seconds: 2));
      for (var i = 0;; i++) {
        yield i;
        await Future<void>.delayed(Duration(seconds: 3));
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
