import 'package:flutter/material.dart';
import 'package:owl/stop_page.dart';
import 'package:owl/dictionary_selection_page.dart';
import 'package:owl/database/common_helper.dart';

class StartPage extends StatelessWidget {

  CommonHelper ch = CommonHelper();

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
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DictionarySelectionPage()),
          );
        },
        tooltip: 'Change dictionary',
        child: Icon(Icons.library_books),
      ),
    );
  }
}
