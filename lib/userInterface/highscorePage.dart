import 'package:flutter/material.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HighScorePage extends StatefulWidget {
  @override
  _HighScorePageState createState() => _HighScorePageState();
}

class _HighScorePageState extends State<HighScorePage> {
  Future _loadHighScore;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    //_loadHighScore = loadHighScore();
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
                return ListTile(
                  title: Text('${document['username']}'),
                  trailing: Text('${document['classicHighscoreSP']}'),
                );
              }).toList(),
              /*itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                  );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },*/
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