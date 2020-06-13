import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class StopPage extends StatefulWidget {
  @override
  _StopPage createState() => _StopPage();
}

class _StopPage extends State<StopPage> {

  FlutterTts flutterTts;
  bool playing;
  Completer completer;

  final StreamController<int> _streamController = StreamController<int>(
      onCancel: () {
        print("Cancel Handler");
      }
  );

  @override
  void initState()  {
    super.initState();
    initTts();
    initStream();
  }

  void initTts() async {
    flutterTts  = FlutterTts();

    await flutterTts.isLanguageAvailable("en-US");
    playing = false;
    flutterTts.setStartHandler(() {
      setState(() {
        print('start saying');
        assert(playing == false);
        playing = true;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        print('saying complete');
        assert(playing == true);
        playing = false;
        print('completer.complete');
        completer.complete();
      });
    });
  }

  void initStream() {
    _streamController.addStream((() async* {
      await Future<void>.delayed(Duration(seconds: 1));
      for (var i = 0;; i++) {
        await say("dog");
        print("continue");
        await say("cat");
        yield i;
        await Future<void>.delayed(Duration(seconds: 1));
      }
    })());

  }

  Future say(String word) {
    completer = Completer();
    print("Inside say");
    assert(playing == false);
    print("Inside say after assert");
    flutterTts.speak(word).then((resp) {
      print("Inside success");
      print(resp);
      return resp;
    }, onError: (obj, st) {
      print("Inside error");
      print(obj);
      print(st.toString());
    });
    return completer.future;
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
