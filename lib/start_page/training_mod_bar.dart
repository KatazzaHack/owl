import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:owl/start_page/training_mod_model.dart';

class TrainingModBar extends StatefulWidget {
  TrainingModBar({Key key}) : super(key: key);

  @override
  _TrainingModBarState createState() => _TrainingModBarState();
}

class _TrainingModBarState extends State<TrainingModBar> {
  void _onItemTapped(int index) {
    Provider.of<TrainingModModel>(context, listen: false).setState(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingModModel>(
      builder: (context, trainingMod, child) {
        assert(trainingMod != null);
        return BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              title: Text('Test yourself'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.speaker),
              title: Text('Passive listening'),
            ),
          ],
          currentIndex: trainingMod.state,
          onTap: _onItemTapped,
        );
      },
    );
  }
}
