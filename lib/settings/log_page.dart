import 'dart:io';

import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:owl/utils.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';

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
                          child: Text('Save to Downloads'),
                          onPressed: () async {
                            final downloadsDirectory =
                              await DownloadsPathProvider.downloadsDirectory;
                            File logs = new File(
                                downloadsDirectory.path + '/owl_logs.txt');
                            logs.writeAsStringSync(_logText);
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text(
                                    'Saved to Downloads as owl_logs.txt')));
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
