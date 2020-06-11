import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:quiz_match/userInterface/gamePage.dart';
import 'package:quiz_match/userInterface/loginPage.dart';
import 'package:quiz_match/userInterface/settingsPage.dart';
import 'package:quiz_match/userInterface/highscorePage.dart';

class GameSelectionPage extends StatefulWidget {
  @override
  _GameSelectionPageState createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future _loadHighScores;
  var _userHighScores;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _loadHighScores = loadHighscores();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: signOutDialog,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => toPage(SettingsPage()),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.equalizer),
              onPressed: () => toPage(HighScorePage()),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _loadHighScores,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Swiper(
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return gameCardList(index);
                },
                viewportFraction: 0.8,
                scale: 0.9,
                loop: false,
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget gameCardList(int index) {
    if (index == 0) {
      return classicSPCard();
    } else if (index == 1) {
      return questionSPCard(5);
    } else if (index == 2) {
      return questionSPCard(10);
    } else if (index == 3) {
      return questionSPCard(15);
    }
    // TODO weitere Spielmodi implementieren
  }

  Widget classicSPCard() {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.fromLTRB(10, 120, 10, 70),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 12.0),
        child: Column(
          children: <Widget>[
            Text(
              'Klassisch',
              style: TextStyle(fontSize: 32.0, letterSpacing: 1.2),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Text(
                'Spiele zufällige Kategorien und schlage den Highscore.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                'Bestes Ergebnis:\n${_userHighScores['classicHighscorePSP']}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 60.0),
              child: Text(
                'Meiste richtige Antworten:\n${_userHighScores['classicHighscoreRASP']}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Divider(color: Colors.white),
            FlatButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (BuildContext context) => GamePage(0)), ModalRoute.withName('/')),
              child: Text(
                'Spielen',
                style: TextStyle(fontSize: 18.0, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget questionSPCard(int numberQuestions) {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.fromLTRB(10, 120, 10, 70),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 12.0),
        child: Column(
          children: <Widget>[
            Text(
              '$numberQuestions Fragen',
              style: TextStyle(fontSize: 32.0, letterSpacing: 1.2),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Text(
                'Spiele $numberQuestions Fragen und beantworte soviel wie möglich richtig und schlage den Highscore.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'Beste Punktzahl:\n${_userHighScores['questionHighscorePSP$numberQuestions']}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 30.0),
              child: Text(
                'Meiste richtige Antworten:\n${_userHighScores['questionHighscoreRASP$numberQuestions']}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Divider(color: Colors.white),
            FlatButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (BuildContext context) => GamePage(1, numberQuestions)), ModalRoute.withName('/')),
              child: Text(
                'Spielen',
                style: TextStyle(fontSize: 18.0, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadHighscores() async {
    FirebaseUser user = await _auth.currentUser();
    _userHighScores = await Firestore.instance.collection('users').document(user.uid).get();
  }

  Future<bool> signOutDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text('Ausloggen?'),
            content: Text('Willst du dich wirklich ausloggen?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Nein'),
              ),
              FlatButton(
                onPressed: () => signOut(),
                child: Text('Ja'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void toPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), ModalRoute.withName('/'));
  }
}
