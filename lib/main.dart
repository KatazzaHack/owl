import 'package:flutter/material.dart';
import 'package:owl/start_page.dart';
import 'package:owl/training_mod_model.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(OWLApp());
}

class OWLApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Owl Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (context) => TrainingModModel(),
        child: StartPage(),
      ),
    );
  }
}
