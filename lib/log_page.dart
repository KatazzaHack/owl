import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:owl/utils.dart';

class LogPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: Text("Logs"),
        ),
      ),
      body: Container(
          child: FutureBuilder<List<Log>>(
            future: FLog.getAllLogs(),
            builder: (BuildContext context, AsyncSnapshot<List<Log>> snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: new Text(getText(snapshot.data)),
                );
              } else {
                return CircularProgressIndicator();
              }
            }
          )
      )
    );
  }
}

String getText(List<Log> logs) {
  var buffer = StringBuffer();
  LogsConfig config = FLog.getDefaultConfigurations()
    ..isDevelopmentDebuggingEnabled = true
    ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3
    ..formatType = FormatType.FORMAT_CUSTOM
    ..fieldOrderFormatCustom = [
      FieldName.TIMESTAMP,
      FieldName.LOG_LEVEL,
      FieldName.CLASSNAME,
      FieldName.METHOD_NAME,
      FieldName.TEXT,
      FieldName.EXCEPTION,
      FieldName.STACKTRACE
    ]
    ..customOpeningDivider = "|"
    ..customClosingDivider = "|";
  logs.forEach((log) {
    buffer.write(Formatter.format(log, config));
  });

  return buffer.toString();
}