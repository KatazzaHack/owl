import 'package:flutter/material.dart';
import 'package:owl/stop_page.dart';
import 'package:owl/dictionary_selection_page.dart';
import 'package:owl/settings/listen_mode.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: Text("Oral word learning"),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              // leading: ListenModeCheckBox(),
              leading: Text("checkbox"),
            ),
          ],
        ),
      ),
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
