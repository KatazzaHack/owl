import 'package:flutter/material.dart';
import 'package:owl/start_page/start_page.dart';
import 'package:owl/start_page/training_mod_model.dart';
import 'package:provider/provider.dart';
import 'package:owl/dictionaries_model.dart';

void main() async {
  runApp(OWLApp());
}

class OWLApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DictionariesModel(),
      child: MaterialApp(
        title: 'Owl Application',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MultiProvider(providers: [
          ChangeNotifierProvider(create: (context) => TrainingModModel()),
        ], child: StartPage()),
      ),
    );
  }
}
