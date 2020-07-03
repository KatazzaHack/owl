import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'dart:async';

import 'package:owl/words.dart';
import 'package:owl/tts/tts_helper.dart';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {
  WordList wl = WordList.instance;

  final StreamController<String> _streamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    initStream();
  }

  void initStream() {
    _streamController.addStream((() async* {
      for (var i = 0;; i++) {
        String word = await wl.getNextWord();
        yield word;
        await Future<void>.delayed(Duration(seconds: 1));
        await TtsHelper().say(word);
        await Future<void>.delayed(Duration(seconds: 1));
      }
    })());
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                body: Container(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AutoSizeText("${snapshot.data}",
                              style: TextStyle(fontSize: 100), maxLines: 1),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: RaisedButton(
                                  shape: CircleBorder(),
                                  color: Colors.red,
                                  onPressed: () {
                                    TtsHelper().stop();
                                    Navigator.pop(context);
                                  },
                                  child: AutoSizeText(
                                    "STOP",
                                    style: TextStyle(fontSize: 20),
                                    maxLines: 1,
                                  ))),
                        ])));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
