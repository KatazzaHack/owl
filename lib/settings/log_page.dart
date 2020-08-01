import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:owl/utils.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';

String getText(List<Log> logs) {
  var buffer = StringBuffer();
  LogsConfig config = getLogConfig();
  logs.forEach((log) {
    buffer.write(Formatter.format(log, config));
  });

  return buffer.toString();
}

void downloadLogs() async {
  List<Log> ll = await FLog.getAllLogs();
  String lT = getText(ll);
  final downloadsDirectory =
  await DownloadsPathProvider.downloadsDirectory;
  File logs = new File(
      downloadsDirectory.path + '/owl_logs.txt');
  logs.writeAsStringSync(lT);
}
