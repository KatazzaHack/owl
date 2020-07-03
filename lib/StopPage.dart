import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'Words.dart';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {
  FlutterTts flutterTts;
  bool playing;
  Completer completer;
  WordList wl = WordList.instance;

  final StreamController<String> _streamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    initTts();
    initStream();
  }

  void initTts() async {
    flutterTts = FlutterTts();

    await flutterTts.isLanguageAvailable("en-US");
    playing = false;
    flutterTts.setStartHandler(() {
      setState(() {
        assert(playing == false);
        playing = true;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        assert(playing == true);
        playing = false;
        completer.complete();
      });
    });
  }

  void initStream() {
    _streamController.addStream((() async* {
      for (var i = 0;; i++) {
        String word = await wl.getRandomWord();
        yield word;
        await Future<void>.delayed(Duration(seconds: 4),
          () => print('Waited for 4 sec'));
        say(word);
        Future<void> future = say(word);
        future.then((value) => print("Future returned"))
          .catchError((error) => print("Error happend"));
        await Future<void>.delayed(Duration(seconds: 4), () => print('Waited for 4 sec'));
      }
    })());
  }

  Future say(String word) {
    completer = Completer();
    assert(playing == false);
    flutterTts.speak(word).then((resp) {
      print(resp);
      return resp;
    }, onError: (obj, st) {
      print(obj);
      print(st.toString());
    });
    return completer.future;
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
