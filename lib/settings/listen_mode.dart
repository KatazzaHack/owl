import 'package:flutter/material.dart';

class ListenModeCheckBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: Future.value(1),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return Text("");
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}