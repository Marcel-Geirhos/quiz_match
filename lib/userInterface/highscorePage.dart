import 'package:flutter/material.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HighScorePage extends StatefulWidget {
  @override
  _HighScorePageState createState() => _HighScorePageState();
}

class _HighScorePageState extends State<HighScorePage> {
  List<String> _highScorePoints = ["Punkte", "Richtige Antworten"];
  List<DropdownMenuItem<String>> _dropdownMenuHighScorePoints;
  String _currentHighScorePoints;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _dropdownMenuHighScorePoints = getDropdownMenuItems();
    _currentHighScorePoints = _dropdownMenuHighScorePoints[0].value;
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
          DropdownButton(
            value: _currentHighScorePoints,
            items: _dropdownMenuHighScorePoints,
            onChanged: changedDropdownHighScorePoints,
            underline: SizedBox(),    // Ohne Unterstrich
          ),
          Container(
            height: MediaQuery.of(context).size.height - 134,   // TODO noch nicht dynamisch genug für verschiedene Geräte
            child: StreamBuilder<QuerySnapshot>(
              stream: loadHighScore().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return CircularProgressIndicator();
                }
                return ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('${document['username']}'),
                          trailing: _currentHighScorePoints == 'Punkte' ? Text('${document['classicHighscorePSP']}') : Text('${document['classicHighscoreRASP']}'),
                        ),
                        Divider(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getDropdownMenuItems() {
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

  Query loadHighScore() {
    if (_currentHighScorePoints == 'Punkte') {
      return Firestore.instance.collection('users').orderBy('classicHighscorePSP', descending: true).limit(50);
    }
    return Firestore.instance.collection('users').orderBy('classicHighscoreRASP', descending: true).limit(50);
  }
}
