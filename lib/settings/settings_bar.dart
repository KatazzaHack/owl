import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:owl/settings/setting_model.dart';
import 'package:owl/log_page.dart';

class TrainingModBar extends StatefulWidget {
  TrainingModBar({Key key}) : super(key: key);

  @override
  _TrainingModBarState createState() => _TrainingModBarState();
}

class _TrainingModBarState extends State<TrainingModBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        assert(settingsModel != null);
        return SettingsList(
          sections: [
            SettingsSection(
              title: 'Settings',
              tiles: [
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
        );
      },
    );
  }
}
