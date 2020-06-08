import 'package:flutter/material.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HighScorePage extends StatefulWidget {
  @override
  _HighScorePageState createState() => _HighScorePageState();
}

class _HighScorePageState extends State<HighScorePage> {

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Center(
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
                      trailing: Text('${document['classicHighscoreSP']}'),
                    ),
                    Divider(),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Query loadHighScore() {
    return Firestore.instance.collection('users').orderBy('classicHighscoreSP', descending: true).limit(10);
  }
}