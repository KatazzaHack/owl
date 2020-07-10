import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListenModeCheckBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.hasData) {
            return Checkbox(
                value: snapshot.data.getBool(ConstVariables.listen_mode),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}