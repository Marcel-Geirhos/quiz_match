import 'dart:math';
import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_match/userInterface/gameSelectionPage.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> _answerKeyList;
  List<String> _resultList;
  List<bool> _answerVisibility;
  List<Icon> _icon;
  LinkedHashMap _solutionMap;
  LinkedHashMap _solution;
  int _selectedAnswerIndex;
  int _selectedResultIndex;
  int _answerCounter;
  int _pointsCounter;
  int _roundCounter;
  int _answerNumber;
  int _countdownValue;
  Timer _timer;
  Future _loadQuestion;
  var _question;
  Color _countdownColor;
  bool _showResults;
  bool _isGameOver;
  String _nextStepButtonText;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
    _pointsCounter = 0;
    _roundCounter = 0;
    _isGameOver = false;
    startNewRound();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadQuestion,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _answerCounter = 0;
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 36.0, left: 12.0),
                      child: Text(
                        'Runde\n$_roundCounter',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 38.0),
                      child: Text(
                        '$_countdownValue',
                        style: TextStyle(fontSize: 24.0, letterSpacing: 1.8, color: _countdownColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 36.0, right: 12.0),
                      child: Text(
                        'Punkte\n$_pointsCounter',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                  child: Text(
                    _question['questionText'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                answerArea(),
                Divider(color: Colors.white),
                resultArea(),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// Auswählbarer Antwortenbereich (obere Bildschirmhälfte)
  Widget answerArea() {
    return Column(
      children: List.generate(
        _answerNumber - 2,
        (index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2,
              (index2) {
                _answerCounter++;
                if (_answerNumber >= _answerCounter) {
                  return Visibility(
                    visible: _answerVisibility[_answerCounter - 1],
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: ChoiceChip(
                        label: Container(
                          width: 100,
                          child: AutoSizeText(
                            _answerKeyList[_answerCounter - 1],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                        selected: _selectedAnswerIndex == index * 2 + index2,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAnswerIndex = index * 2 + index2;
                            // Ergebnisfeld wird mit Antwort ausgetauscht
                            if (_selectedResultIndex != -1) {
                              var temp = _resultList[_selectedResultIndex];
                              _resultList[_selectedResultIndex] = _answerKeyList[_selectedAnswerIndex];
                              _answerKeyList[_selectedAnswerIndex] = temp;
                              _selectedResultIndex = -1;
                              _selectedAnswerIndex = -1;
                            }
                          });
                        },
                        selectedColor: Color(0xffffc107),
                      ),
                    ),
                  );
                } else {
                  return Text('');
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// Unterer Ergebnisbereich (untere Bildschirmhälfte)
  Widget resultArea() {
    return Column(
      children: <Widget>[
        Text(
          _question['topText'],
          style: TextStyle(fontSize: 20.0),
        ),
        Column(
          children: List.generate(
            _answerNumber,
            (index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    child: Visibility(
                      visible: _showResults,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: _showResults ? _icon[index] : Icon(Icons.close),
                    ),
                    padding: EdgeInsets.only(right: 70.0),
                  ),
                  GestureDetector(
                    onTap: () => setSelectedText(index),
                    child: ChoiceChip(
                      label: Container(
                        width: 150,
                        child: AutoSizeText(
                          _resultList[index]?.toString() ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      selected: _selectedResultIndex == index,
                      selectedColor: Color(0xffffc107),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Text(
          _question['bottomText'],
          style: TextStyle(fontSize: 20.0),
        ),
        Visibility(
          visible: _showResults,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: RaisedButton(
            onPressed: () => nextStep(),
            child: Text(_nextStepButtonText),
          ),
        )
      ],
    );
  }

  void startNewRound() {
    _roundCounter++;
    _nextStepButtonText = 'Ergebnisse anzeigen';
    _showResults = false;
    _answerCounter = 0;
    _selectedAnswerIndex = -1;
    _selectedResultIndex = -1;
    _loadQuestion = loadQuestionData();
  }

  /// Zuerst werden die Frage Dokumente aus der Cloud Firestore geladen und anschließend wird zufällig eine
  /// Frage ausgewählt. Danach werden die Fragedaten über [_question] abgespeichert und können über
  /// _question['CloudFirestoreEintrag'] z.B. _question['questionText'] abgefragt werden.
  Future<void> loadQuestionData() async {
    Random random = new Random();
    QuerySnapshot questionList = await Firestore.instance.collection('questions').getDocuments();
    int randomQuestion = random.nextInt(questionList.documents.length);
    _question = questionList.documents[randomQuestion];
    chooseAnswersAndRememberSolution();
    prepareQuestion();
    startTimer();
  }

  /// Zuerst werden die Key/Value Pairs die in der Cloud Firestore bei jeder Frage als Map hinterlegt sind
  /// in zwei Listen geschrieben um leichter auf diese zugreifen zu können.
  /// Anschließend werden folgende Schritte durchgeführt:
  /// 1. Alle Antworten werden aus der Map ausgelesen (Key Werte) und in eine Liste geladen.
  /// 2. Die Antwortenliste wird zufällig durchgemischt (shuffle).
  /// 3. Es werden zufällig die ersten 4-6 Antworten aus der Liste genommen.
  /// 4. Es wird die richtige Lösung für diese Antworten vermerkt in [_solution]
  void chooseAnswersAndRememberSolution() {
    Random random = new Random();
    List<String> allAnswerKeys = _question.data['answers'].keys.toList();
    List<dynamic> answerValueList = _question.data['answers'].values.toList();
    _solution = new LinkedHashMap();
    _answerKeyList = _question.data['answers'].keys.toList();
    _answerKeyList.shuffle();
    _answerNumber = 4 + random.nextInt(6 - 4);   // 4 - 6 Antworten möglich
    _answerKeyList = _answerKeyList.sublist(0, _answerNumber);
    for (int i = 0; i < _answerKeyList.length; i++) {
      for (int j = 0; j < _question.data['answers'].length; j++) {
        if (_answerKeyList[i].compareTo(allAnswerKeys[j]) == 0) {
          _solution[_answerKeyList[i]] = answerValueList[j];
        }
      }
    }
  }

  void prepareQuestion() {
    _countdownValue = 5 * _answerNumber;
    _resultList = new List(_answerNumber);
    _answerVisibility = new List(_answerNumber);
    for (int i = 0; i < _answerNumber; i++) {
      _answerVisibility[i] = true;
      _resultList[i] = '';
    }
  }

  void startTimer() {
    const oneSecond = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSecond,
          (Timer timer) => setState(
            () {
          if (_countdownValue < 1) {
            timer.cancel();
            _countdownColor = Colors.white;
            showRightAndWrongAnswers();
          } else {
            if (_countdownValue <= 6) {
              _countdownColor = Colors.red;
            } else {
              _countdownColor = Colors.white;
            }
            _countdownValue--;
          }
        },
      ),
    );
  }

  void showRightAndWrongAnswers() {
    _showResults = true;
    /// Sortiert die komplette Antwortenliste absteigend vom höchsten zum niedrigsten.
    var sortedKeys = _solution.keys.toList(growable: false)..sort((k1, k2) => _solution[k2].compareTo(_solution[k1]));
    _solutionMap = new LinkedHashMap.fromIterable(sortedKeys, key: (k) => k, value: (k) => _solution[k]);
    _icon = new List(_resultList.length);
    for (int i = 0; i < _resultList.length; i++) {
      if (_resultList[i] == _solutionMap.keys.elementAt(i)) {
        _icon[i] = Icon(Icons.done, color: Colors.green);
        _pointsCounter++;
      } else {
        _icon[i] = Icon(Icons.close, color: Colors.red);
        _isGameOver = true;
      }
    }
  }

  /// Mit Antworten sind hier die in der oberen Hälfte des Bildschirms angezeigten Chips gemeint.
  /// Mit Ergebnisfeld sind hier die in der unteren Hälfte des Bildschirms angezeigten Chips gemeint.
  void setSelectedText(int resultIndex) {
    setState(() {
      /// Antwort ist ausgewählt
      if (_selectedAnswerIndex != -1) {
        /// Ergebnisfeld ist leer
        if (_resultList[resultIndex] == '') {
          _resultList[resultIndex] = _answerKeyList[_selectedAnswerIndex];
          _answerVisibility[_selectedAnswerIndex] = false;
          _selectedAnswerIndex = -1;
        }
        /// Ergebnisfeld ist nicht leer
        else {
          var temp = _resultList[resultIndex];
          _resultList[resultIndex] = _answerKeyList[_selectedAnswerIndex];
          _answerKeyList[_selectedAnswerIndex] = temp;
          _selectedAnswerIndex = -1;
        }
      }
      /// Ergebnis ist ausgewählt
      else {
        if (_selectedResultIndex == -1) {
          _selectedResultIndex = resultIndex;
          return;
        }
        /// Ergebnisfeld ist leer
        if (_resultList[resultIndex] == '') {
          _resultList[resultIndex] = _resultList[_selectedResultIndex];
          _resultList[_selectedResultIndex] = '';
          _selectedResultIndex = -1;
        }
        /// Ergebnisfeld ist nicht leer
        else {
          var temp = _resultList[resultIndex];
          _resultList[resultIndex] = _resultList[_selectedResultIndex];
          _resultList[_selectedResultIndex] = temp;
          _selectedResultIndex = -1;
        }
      }
    });
  }

  void nextStep() {
    if (_nextStepButtonText == 'Ergebnisse anzeigen') {
      showResults();
    } else if (_nextStepButtonText == 'Nächste Frage') {
      startNewRound();
    } else {
      // Game Over
      showDialog(
        context: context,
        builder: (_) => gameOverDialog(),
      );
    }
  }

  Widget gameOverDialog() {
    return AlertDialog(
      title: Text(
        'Game Over',
        textAlign: TextAlign.center,
      ),
      content: Text('Erreichte Punktzahl: $_pointsCounter'),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Spiel beenden',
            textAlign: TextAlign.center,
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) => GameSelectionPage()), ModalRoute.withName('/')),
        ),
      ],
      elevation: 24.0,
    );
  }

  void showResults() {
    for (int i = 0; i < _resultList.length; i++) {
      _resultList[i] = _solutionMap.keys.elementAt(i);
    }
    setState(() {
      if (_isGameOver) {
        _nextStepButtonText = 'Spiel beenden';
        updateHighscore();
      } else {
        _nextStepButtonText = 'Nächste Frage';
      }
    });
  }

  void updateHighscore() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    bool isNewHighscore = await checkNewHighscore(user);
    if (isNewHighscore) {
      Firestore.instance.collection('users').document(user.uid).updateData({
        'classicHighscoreSP': _pointsCounter,
      });
    }
  }

  Future<bool> checkNewHighscore(FirebaseUser user) async {
    var userData = await Firestore.instance.collection('users').document(user.uid).get();
    // Neuer Highscore
    if (_pointsCounter > userData['classicHighscoreSP']) {
      return true;
    }
    return false;
  }
}
