import 'package:flutter/material.dart';
import 'package:owl/const_variables.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:owl/settings/setting_model.dart';
import 'package:owl/log_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                    onTap: _launchURL,
                  ),
                  SettingsTile(
                    title: 'Logs',
                    leading: Icon(Icons.description),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return LogPage();
                      }));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _launchURL() async {
    String url = ConstVariables.FeedbackURL;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
