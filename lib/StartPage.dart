import 'package:flutter/material.dart';
import 'StopPage.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: ClipOval(
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return StopPage();
                  }));
                },
                child: Text("Start"),
              ),
            )
        )
    );
  }
}
