import 'package:flutter/material.dart';
import 'package:owl/settings/settings_bar.dart';
import 'package:owl/stop_page.dart';
import 'package:owl/dictionary/dictionary_selection_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:owl/database/common_helper.dart';
import 'package:owl/start_page/training_mod_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CommonHelper ch = CommonHelper();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return SettingsPage();
                }));
              })
        ],
      ),
      body: Column(
          children: signInButtons(context)),
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
      bottomNavigationBar: TrainingModBar(),
    );
  }
}

List<Widget> signInButtons(BuildContext context) {
  List<Widget> result = [Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        child: RaisedButton(
          shape: CircleBorder(),
          color: Colors.green,
          onPressed: () async {
            PermissionStatus status = await Permission.microphone.request();
            if (status.isGranted) {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return StopPage();
              }));
            } else if (status.isPermanentlyDenied) {
              openAppSettings();
            }
          },
          child: Text("START", style: TextStyle(fontSize: 40)),
        ),
      )),
  ];
  if (FirebaseAuth.instance.currentUser == null) {
    result.add(SignInButton(
      Buttons.Google,
      text: "Sign in with Google",
      onPressed: () {signInWithGoogle();},
    ));
  }
  return result;
}
Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // sawait Firebase.initializeApp();
  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
