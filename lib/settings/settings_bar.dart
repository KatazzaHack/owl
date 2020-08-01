import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:owl/settings/setting_model.dart';
import 'package:owl/settings/log_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:owl/settings/speed_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:owl/dictionary/dictionary_validator.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _onItemTapped() {
    Provider.of<SettingsModel>(context, listen: false).perhapsInit();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        assert(settingsModel != null);
        return Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: SettingsList(
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: 'Send Feedback',
                    leading: Icon(Icons.feedback),
                    onTap: (){_launchURL(ConstVariables.FeedbackURL);},
                  ),
                  SettingsTile(
                    title: 'FAQ',
                    leading: Icon(Icons.help),
                    onTap: (){_launchURL(ConstVariables.FAQURL);},
                  ),
                  SettingsTile(
                    title: 'Speed Settings',
                    leading: Icon(Icons.timer),
                    onTap: () {
                      _onItemTapped();
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return SpeedPage();
                      }));
                    },
                  ),
                  SettingsTile(
                    title: 'Save Logs',
                    leading: Icon(Icons.description),
                    onTap: () async {
                      PermissionStatus status =
                          await Permission.storage.request();
                      if (status.isGranted) {
                        downloadLogs();
                        DictionaryValidator dv = DictionaryValidator(context);
                        dv.showAlertDialog("Success",
                            "Saved to Downloads folder as owl_logs.txt", "Ok");
                      } else {
                        if (status.isPermanentlyDenied) {
                          openAppSettings();
                        }
                      }
                    },
                  ),
                  SettingsTile(
                    title: 'Report Bug',
                    leading: Icon(Icons.bug_report),
                    onTap: (){_launchURL(ConstVariables.BugReportURL);},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
