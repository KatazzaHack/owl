import 'package:flutter/material.dart';
import 'package:owl/settings/setting_model.dart';
import 'package:provider/provider.dart';

class SpeedPage extends StatefulWidget {
  @override
  _SpeedPageState createState() => _SpeedPageState();
}

class _SpeedPageState extends State<SpeedPage> {
  void _onItemTapped(int speed) {
    Provider.of<SettingsModel>(context, listen: false).setSpeedLimit(speed);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        assert(settingsModel != null);
        double _speed = settingsModel.speedLimit + 0.0;
        return Scaffold(
            appBar: AppBar(title: Text('Speed settings')),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 24.0),
                    child: Text("Pronounce speed", style: TextStyle(fontSize: 35), ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue[700],
                      inactiveTrackColor: Colors.blue[100],
                      trackShape: RoundedRectSliderTrackShape(),
                      trackHeight: 4.0,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      thumbColor: Colors.blueAccent,
                      overlayColor: Colors.blue.withAlpha(32),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                      tickMarkShape: RoundSliderTickMarkShape(),
                      activeTickMarkColor: Colors.blue[700],
                      inactiveTickMarkColor: Colors.blue[100],
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      valueIndicatorColor: Colors.blueAccent,
                      valueIndicatorTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    child: Slider(
                      value: _speed,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _slider_label(_speed),
                      onChanged: (value) {
                        setState(
                          () {
                            _speed = value;
                            _onItemTapped(_speed.round());
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  String _slider_label(double value) {
    int iValue = value.round();
    return "$iValue s";
  }
}
