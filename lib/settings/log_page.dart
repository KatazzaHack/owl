import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:owl/utils.dart';

class LogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text("Logs"),
          ),
        ),
        body: Container(
            child: FutureBuilder<List<Log>>(
                future: FLog.getAllLogs(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Log>> snapshot) {
                  if (snapshot.hasData) {
                    String _logText = getText(snapshot.data);
                    return ListView(
                      children: <Widget>[
                        RaisedButton(
                          child: Text('Copy to Clipboard'),
                          onPressed: () {
                            ClipboardManager.copyToClipBoard(_logText)
                                .then((result) {
                              final snackBar = SnackBar(
                                content: Text('Copied to Clipboard'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {},
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                            });
                          },
                        ),
                      ] + buildTextLog(snapshot.data)
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                })));
  }
}

String getText(List<Log> logs) {
  var buffer = StringBuffer();
  LogsConfig config = getLogConfig();
  logs.forEach((log) {
    buffer.write(Formatter.format(log, config));
  });

  return buffer.toString();
}

List<Widget> buildTextLog(List<Log> logs) {
  List<Widget> result = [];
  LogsConfig config = getLogConfig();
  logs.forEach((log) {
    result.add(Text(Formatter.format(log, config)));
  });
  return result;
}
