import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:quiz_match/utils/systemSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> _answerKeyList;
  List<String> _resultList;
  List<bool> _answerVisibility;
  List<dynamic> _answerValueList;
  int _selectedAnswerIndex;
  int _selectedResultIndex;
  int _answerCounter;
  int _countdown;
  Timer _timer;
  Future _loadQuestion;
  var _question;
  Color _countdownColor;

  @override
  void initState() {
    super.initState();
    SystemSettings.allowOnlyPortraitOrientation();
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
                Padding(
                  padding: const EdgeInsets.only(top: 44.0),
                  child: Text(
                    '$_countdown',
                    style: TextStyle(fontSize: 24.0, letterSpacing: 1.8, color: _countdownColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
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
        _answerKeyList.length.round(),
        (index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              2,
              (index2) {
                _answerCounter++;
                if (_answerKeyList.length >= _answerCounter) {
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
        Text(_question['topText']),
        Column(
          children: List.generate(
            _question['answers'].length,
            (index) {
              return GestureDetector(
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
                  selectedColor: Colors.green,
                ),
              );
            },
          ),
        ),
        Text(_question['bottomText']),
      ],
    );
  }

  void setSelectedText(int resultIndex) {
    setState(() {
      // Antwort ist ausgewählt
      if (_selectedAnswerIndex != -1) {
        // Ergebnisfeld ist leer
        if (_resultList[resultIndex] == '') {
          _resultList[resultIndex] = _answerKeyList[_selectedAnswerIndex];
          _answerVisibility[_selectedAnswerIndex] = false;
          _selectedAnswerIndex = -1;
        }
        // Ergebnisfeld ist nicht leer
        else {
          var temp = _resultList[resultIndex];
          _resultList[resultIndex] = _answerKeyList[_selectedAnswerIndex];
          _answerKeyList[_selectedAnswerIndex] = temp;
          _selectedAnswerIndex = -1;
        }
      }
      // Ergebnis ist ausgewählt
      else {
        if (_selectedResultIndex == -1) {
          _selectedResultIndex = resultIndex;
          return;
        }
        // Ergebnisfeld ist leer
        if (_resultList[resultIndex] == '') {
          _resultList[resultIndex] = _resultList[_selectedResultIndex];
          _resultList[_selectedResultIndex] = '';
          _selectedResultIndex = -1;
        }
        // Ergebnisfeld ist nicht leer
        else {
          var temp = _resultList[resultIndex];
          _resultList[resultIndex] = _resultList[_selectedResultIndex];
          _resultList[_selectedResultIndex] = temp;
          _selectedResultIndex = -1;
        }
      }
    });
  }

  void startTimer() {
    const oneSecond = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSecond,
      (Timer timer) => setState(
        () {
          if (_countdown < 1) {
            timer.cancel();
            startNewRound();
          } else {
            if (_countdown <= 6) {
              _countdownColor = Colors.red;
            } else {
              _countdownColor = Colors.white;
            }
            _countdown--;
          }
        },
      ),
    );
  }

  /*

   */
  Future<void> loadQuestionData() async {
    QuerySnapshot questionList = await Firestore.instance.collection('questions').getDocuments();
    Random random = new Random();
    int randomNumber = random.nextInt(questionList.documents.length);
    _question = questionList.documents[randomNumber];
    _answerKeyList = _question.data['answers'].keys.toList();
    _answerValueList = _question.data['answers'].values.toList();
    var answers = new Map();
    for (int i = 0; i < _answerKeyList.length; i++) {
      answers[_answerKeyList[i]] = _answerValueList[i];
    }
    answers.entries.toList();
    _answerKeyList.shuffle();
    _countdown = 5 * _answerKeyList.length;
    _resultList = new List(_answerKeyList.length);
    for (int i = 0; i < _resultList.length; i++) {
      _resultList[i] = '';
    }
    _answerVisibility = new List(_answerKeyList.length);
    for (int i = 0; i < _answerKeyList.length; i++) {
      _answerVisibility[i] = true;
    }
    startTimer();
  }

  void startNewRound() {
    _answerCounter = 0;
    _selectedAnswerIndex = -1;
    _selectedResultIndex = -1;
    _countdownColor = Colors.white;
    _loadQuestion = loadQuestionData();
  }
}
