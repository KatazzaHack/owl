import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:owl/stop_page.dart';
import 'package:owl/dictionary_selection_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:owl/database/common_helper.dart';
import 'package:owl/start_page/training_mod_bar.dart';

class StartPage extends StatelessWidget {

  CommonHelper ch = CommonHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: RaisedButton(
          shape: CircleBorder(),
          color: Colors.blue,
          onPressed: ()  {
            FLog.printDataLogs(dataLogsType: [
              DataLogType.DEVICE.toString(),
            ], logLevels: [
              LogLevel.ERROR.toString(),
              LogLevel.WARNING.toString(),
              LogLevel.INFO.toString()
            ],
            );
          },
        ),
        title: Container(
          alignment: Alignment.center,
          child: Text("Oral word learning"),
        ),
      ),
        body: Container(
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
            )
        ),
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
