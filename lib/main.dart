import 'package:flutter/material.dart';
import 'package:owl/start_page/start_page.dart';
import 'package:owl/start_page/training_mod_model.dart';
import 'package:owl/utils.dart';
import 'package:provider/provider.dart';
import 'package:owl/dictionary/dictionaries_model.dart';
import 'package:f_logs/f_logs.dart';
import 'package:owl/settings/setting_model.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  FLog.applyConfigurations(getLogConfig());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(OWLApp());
}


class OWLApp extends StatelessWidget {
  // This widget is the root of your application.

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => TrainingModModel()),
                ChangeNotifierProvider(
                    create: (context) => DictionariesModel()),
                ChangeNotifierProvider(create: (context) => SettingsModel()),
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
          return CircularProgressIndicator();
        });
  }
}
