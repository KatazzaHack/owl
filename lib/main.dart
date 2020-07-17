import 'package:flutter/material.dart';
import 'package:owl/start_page/start_page.dart';
import 'package:owl/start_page/training_mod_model.dart';
import 'package:provider/provider.dart';
import 'package:owl/dictionaries_model.dart';
import 'package:f_logs/f_logs.dart';

void main() async {
  init();
  runApp(OWLApp());
}

void init() {
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

  FLog.applyConfigurations(config);
}

class OWLApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TrainingModModel()),
        ChangeNotifierProvider(create:(context) => DictionariesModel()),
      ],
      child: MaterialApp(
        title: 'Owl Application',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StartPage(),
      ),
    );
  }
}
