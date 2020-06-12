import 'package:flutter/material.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HighScorePage extends StatefulWidget {
  @override
  _HighScorePageState createState() => _HighScorePageState();
}

class _HighScorePageState extends State<HighScorePage> {
  // Beste Punktzahl oder Richtige Antworten Auswahl
  List<String> _highScorePoints = ['Beste Punktzahl', 'Richtige Antworten'];
  List<DropdownMenuItem<String>> _dropdownMenuHighScorePoints;
  String _currentHighScorePoints;

  // Spielmodus Auswahl
  List<String> _highScoreGameMode = ['Klassik', '5 Fragen', '10 Fragen', '15 Fragen'];
  List<DropdownMenuItem<String>> _dropdownMenuHighScoreGameMode;
  String _currentHighScoreGameMode;

  String _selectedHighScore;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _dropdownMenuHighScorePoints = getDropdownMenuItemsForPoints();
    _dropdownMenuHighScoreGameMode = getDropdownMenuItemsForGameMode();
    _currentHighScorePoints = _dropdownMenuHighScorePoints[0].value;
    _currentHighScoreGameMode = _dropdownMenuHighScoreGameMode[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rangliste'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              DropdownButton(
                value: _currentHighScorePoints,
                items: _dropdownMenuHighScorePoints,
                onChanged: changedDropdownHighScorePoints,
                underline: SizedBox(), // Ohne Unterstrich
              ),
              DropdownButton(
                value: _currentHighScoreGameMode,
                items: _dropdownMenuHighScoreGameMode,
                onChanged: changedDropdownHighScoreGameMode,
                underline: SizedBox(), // Ohne Unterstrich
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height - 134, // TODO noch nicht dynamisch genug für verschiedene Geräte
            child: StreamBuilder<QuerySnapshot>(
              stream: loadHighScore().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return CircularProgressIndicator();
                }
                return ListView(
                  children: List.generate(
                    snapshot.data.documents.length,
                    (index) {
                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text('${snapshot.data.documents[index]['username']}'),
                            trailing: Text('${snapshot.data.documents[index][_selectedHighScore]}'),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForPoints() {
    List<DropdownMenuItem<String>> items = new List();
    for (String highScorePoints in _highScorePoints) {
      items.add(new DropdownMenuItem(value: highScorePoints, child: new Text(highScorePoints)));
    }
    return items;
  }

  void changedDropdownHighScorePoints(String selectedChoice) {
    setState(() {
      _currentHighScorePoints = selectedChoice;
    });
  }

  List<DropdownMenuItem<String>> getDropdownMenuItemsForGameMode() {
    List<DropdownMenuItem<String>> items = new List();
    for (String highScoreGameMode in _highScoreGameMode) {
      items.add(new DropdownMenuItem(value: highScoreGameMode, child: new Text(highScoreGameMode)));
    }
    return items;
  }

  void changedDropdownHighScoreGameMode(String selectedChoice) {
    setState(() {
      _currentHighScoreGameMode = selectedChoice;
    });
  }

  // TODO kann noch verbessert werden
  Query loadHighScore() {
    if (_currentHighScorePoints == 'Beste Punktzahl') {
      if (_currentHighScoreGameMode == 'Klassik') {
        _selectedHighScore = 'classicHighscorePSP';
        return Firestore.instance.collection('users').orderBy('classicHighscorePSP', descending: true).limit(50);
      } else if (_currentHighScoreGameMode == '5 Fragen') {
        _selectedHighScore = 'questionHighscorePSP5';
        return Firestore.instance.collection('users').orderBy('questionHighscorePSP5', descending: true).limit(50);
      } else if (_currentHighScoreGameMode == '10 Fragen') {
        _selectedHighScore = 'questionHighscorePSP10';
        return Firestore.instance.collection('users').orderBy('questionHighscorePSP10', descending: true).limit(50);
      } else if (_currentHighScoreGameMode == '15 Fragen') {
        _selectedHighScore = 'questionHighscorePSP15';
        return Firestore.instance.collection('users').orderBy('questionHighscorePSP15', descending: true).limit(50);
      }
    } else {
      if (_currentHighScoreGameMode == 'Klassik') {
        _selectedHighScore = 'classicHighscoreRASP';
        return Firestore.instance.collection('users').orderBy('classicHighscoreRASP', descending: true).limit(50);
      } else if (_currentHighScoreGameMode == '5 Fragen') {
        _selectedHighScore = 'questionHighscoreRASP5';
        return Firestore.instance.collection('users').orderBy('questionHighscoreRASP5', descending: true).limit(50);
      } else if (_currentHighScoreGameMode == '10 Fragen') {
        _selectedHighScore = 'questionHighscoreRASP10';
        return Firestore.instance.collection('users').orderBy('questionHighscoreRASP10', descending: true).limit(50);
      } else if (_currentHighScoreGameMode == '15 Fragen') {
        _selectedHighScore = 'questionHighscoreRASP15';
        return Firestore.instance.collection('users').orderBy('questionHighscoreRASP15', descending: true).limit(50);
      }
    }
  }
}
