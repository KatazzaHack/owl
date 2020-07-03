import 'package:flutter/material.dart';
import 'stop_page.dart';

class StartPage extends StatelessWidget {
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
                color: Colors.green,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return StopPage();
                  }));
                },
                child: Text("START", style: TextStyle(fontSize: 40)),
              ),
            )
        )
    );
  }
}
