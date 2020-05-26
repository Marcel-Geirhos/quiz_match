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
  List<String> _answerList;
  List<String> _resultList;
  List<bool> _answerVisibility;
  int _selectedAnswerIndex;
  int _selectedResultIndex;
  int _newResultIndex;
  int _answerCounter;
  int _startTime;
  Timer _timer;
  Future _loadQuestion;
  var _question;

  bool test;

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
                    '$_startTime',
                    style: TextStyle(fontSize: 24.0, letterSpacing: 1.8),
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
        _answerList.length.round(),
            (index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              2,
                  (index2) {
                _answerCounter++;
                if (_answerList.length >= _answerCounter) {
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
                            _answerList[_answerCounter - 1],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                        selected: _selectedAnswerIndex == index * 2 + index2,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAnswerIndex = index * 2 + index2;
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
                onTap: () => setSelectedText(_selectedAnswerIndex, index),
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
                  /*onSelected: (selected) {
                    setState(() {
                      _selectedResultIndex = index;
                    });
                  },*/
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

  /*void setSelectedText(int answerIndex, int resultIndex) {
    setState(() {
      _resultList[resultIndex] = _answerList[answerIndex];
      _answerVisibility[answerIndex] = false;
      _selectedAnswerIndex = null;
    });
  }*/

  void setSelectedText(int answerIndex, int resultIndex) {
    setState(() {
      /// Antwort wird von oben ausgewählt und auf Ergebnisliste gesetzt.
      if ((_resultList[resultIndex] == null || _resultList[resultIndex] == '') && test == false) {
        print('1');
        _resultList[resultIndex] = _answerList[answerIndex];
        _answerVisibility[answerIndex] = false;
        _selectedAnswerIndex = null;
      }
      /// Schon gesetztes Ergebnis wird ausgewählt.
      else if ((_resultList[resultIndex] != null && _resultList[resultIndex] != '') && resultIndex != null) {
        test = true;
        print(_resultList[resultIndex]);
        if (_selectedResultIndex != null) {
          print('2.2');
          print(_resultList[resultIndex]);
          print(_resultList[_selectedResultIndex]);
          var temp =_resultList[resultIndex];
          _resultList[resultIndex] = _resultList[_selectedResultIndex];
          _resultList[_selectedResultIndex] = temp;
          _selectedResultIndex = null;
          test = false;
        } else {
          print('2.1');
          _selectedResultIndex = resultIndex;
          _newResultIndex = resultIndex;
          print(_resultList[_selectedResultIndex]);
          print(_resultList[resultIndex]);
          var temp = _resultList[_newResultIndex];
          _resultList[_newResultIndex] = _resultList[resultIndex];
          _resultList[resultIndex] = temp;
        }
      }
      /// Schon gesetztes Ergebnis ist ausgewählt und wird auf anderes Ergebnisfeld verschoben.
      else if ((_resultList[resultIndex] == null || _resultList[resultIndex] == '') && resultIndex != null) {
        print('3');
        _resultList[resultIndex] = _resultList[_selectedResultIndex];
        _resultList[_selectedResultIndex] = '';
        _selectedResultIndex = null;
        print(_resultList[resultIndex]);
        test = false;
      } else if ((_resultList[resultIndex] != null || _resultList[resultIndex] != '') && (_resultList[_selectedResultIndex] == null || _resultList[_selectedResultIndex] == '')) {
        print('4');
        print(_resultList[resultIndex]);
        print(resultIndex);
         // TODO Wechsel von zwei Ergebnisantworten.
      }
    });
  }

  void startTimer() {
    const oneSecond = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSecond,
      (Timer timer) => setState(
        () {
          if (_startTime < 1) {
            timer.cancel();
            startNewRound();
          } else {
            _startTime--;
          }
        },
      ),
    );
  }

  Future<void> loadQuestionData() async {
    QuerySnapshot questionList = await Firestore.instance.collection('questions').getDocuments();
    Random random = new Random();
    int randomNumber = random.nextInt(questionList.documents.length);
    _question = questionList.documents[randomNumber];
    _answerList = _question.data['answers'].keys.toList();
    _resultList = new List(_answerList.length);
    // TODO _startTime = 5 * _answerList.length;
    _answerVisibility = new List(_answerList.length);
    for (int i = 0; i < _answerList.length; i++) {
      _answerVisibility[i] = true;
    }
  }

  void startNewRound() {
    test = false;
    _startTime = 20;
    _selectedAnswerIndex = 0;
    _answerCounter = 0;
    _loadQuestion = loadQuestionData();
    startTimer();
  }
}
