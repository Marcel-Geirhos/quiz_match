import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:quiz_match/userInterface/gamePage.dart';
import 'package:quiz_match/userInterface/loginPage.dart';
import 'package:quiz_match/userInterface/settingsPage.dart';
import 'package:quiz_match/userInterface/highscorePage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          title: Text('Quiz Match'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.cog),
            onPressed: () => toPage(SettingsPage()),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.equalizer,
                size: 30.0,
              ),
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
                'Spiele solange bis zur ersten falschen Antwort.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: pointDescriptionDialog,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(FontAwesomeIcons.medal),
                    ),
                  ),
                  GestureDetector(
                    onTap: pointDescriptionDialog,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40.0),
                      child: Text(
                        _userHighScores == null ? '0' : '${_userHighScores['classicHighscorePSP']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Tooltip(
                      message: 'Richtige Antworten',
                      child: Icon(FontAwesomeIcons.solidCheckCircle),
                    ),
                  ),
                  Tooltip(
                    message: 'Richtige Antworten',
                    child: Text(
                      _userHighScores == null ? '0' : '${_userHighScores['classicHighscoreRASP']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 90.0),
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
                'Spiele $numberQuestions Runden und beantworte soviel Fragen wie möglich richtig.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: pointDescriptionDialog,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(FontAwesomeIcons.medal),
                    ),
                  ),
                  GestureDetector(
                    onTap: pointDescriptionDialog,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40.0),
                      child: Text(
                        _userHighScores == null ? '0' : '${_userHighScores['questionHighscorePSP$numberQuestions']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Tooltip(
                      message: 'Richtige Antworten',
                      child: Icon(FontAwesomeIcons.solidCheckCircle),
                    ),
                  ),
                  Tooltip(
                    message: 'Richtige Antworten',
                    child: Text(
                      _userHighScores == null ? '0' : '${_userHighScores['questionHighscoreRASP$numberQuestions']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 75.0),
            Divider(color: Colors.white),
            FlatButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => GamePage(1, numberQuestions)),
                  ModalRoute.withName('/')),
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

  Future<bool> pointDescriptionDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text('Punktesystem'),
            content: Text(
                'Pro Sekunde: +1\n\nPro richtige Antwort: +15\n\nAlle Antworten richtig: +15'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('OK'),
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
