import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:quiz_match/userInterface/gamePage.dart';
import 'package:quiz_match/userInterface/loginPage.dart';

class GameSelectionPage extends StatefulWidget {
  @override
  _GameSelectionPageState createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => signOut(),
          ),
        ],
      ),
      body: Swiper(
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          return gameCardList(index);
        },
        viewportFraction: 0.8,
        scale: 0.9,
        loop: false,
      ),
    );
  }

  Widget gameCardList(int index) {
    if (index == 0) {
      return classicSPCard();
    } else if (index == 1) {
      return questionSPCard();
    } else if (index == 2) {
      // TODO weitere Spielmodi implementieren.
    }
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
              padding: const EdgeInsets.only(top: 80.0),
              child: Text(
                'Spiele zufällige Kategorien und schlage den Highscore.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 92.0),
              child: Text(
                'Bestes Ergebnis:\n42',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Divider(color: Colors.white),
            FlatButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (BuildContext context) => GamePage()), ModalRoute.withName('/')),
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

  Widget questionSPCard() {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.fromLTRB(10, 120, 10, 70),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 12.0),
        child: Column(
          children: <Widget>[
            Text(
              '10 Fragen',
              style: TextStyle(fontSize: 32.0, letterSpacing: 1.2),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Text(
                'Spiele 10 Fragen und beantworte soviel wie möglich richtig und schlage den Highscore.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 52.0),
              child: Text(
                'Bestes Ergebnis:\n42',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Divider(color: Colors.white),
            FlatButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (BuildContext context) => GamePage()), ModalRoute.withName('/')),
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

  void signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (BuildContext context) => LoginPage()), ModalRoute.withName('/'));
  }
}
