import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> _answerList;
  List<String> _resultList;
  List<double> _answerOpacity;
  int _selectedIndex = 0;
  var _question;
  Timer _timer;
  int _startTime;
  Future loadQuestion;

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Quiz Match',
          style: TextStyle(letterSpacing: 1.4),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: loadQuestion,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      '$_startTime',
                      style: TextStyle(fontSize: 24.0, letterSpacing: 1.8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Text(
                      _question['questionText'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Column(
                    children: List.generate(_question['answers'].length, (index) {
                      return Opacity(
                        opacity: _answerOpacity[index],
                        child: ChoiceChip(
                          label: Text(_answerList[index]),
                          selected: _selectedIndex == index,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedIndex = index;
                              });
                            }
                          },
                          selectedColor: Color(0xffffc107),
                        ),
                      );
                    }),
                  ),
                  Divider(color: Colors.white),
                  Text(_question['topText']),
                  Column(
                    children: List.generate(_question['answers'].length, (index) {
                      return GestureDetector(
                        onTap: () => setSelectedText(_selectedIndex, index),
                        child: ChoiceChip(
                          label: Text(_resultList[index]?.toString() ?? ''),
                          selected: false,
                        ),
                      );
                    }),
                  ),
                  Text(_question['bottomText']),
                ],
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return CircularProgressIndicator();
          }),
    );
  }

  void setSelectedText(int selectedIndex, int index) {
    setState(() {
      _resultList[index] = _answerList[selectedIndex];
      _answerOpacity[index] = 0.0;
      _selectedIndex = 0;
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
    _startTime = 5 * _answerList.length;
    _answerOpacity = new List(_answerList.length);
    for (int i = 0; i < _answerList.length; i++) {
      _answerOpacity[i] = 1.0;
    }
  }

  void startNewRound() {
    loadQuestion = loadQuestionData();
    startTimer();
  }
}
