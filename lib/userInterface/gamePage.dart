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
  List<bool> _answerOpacity;
  int _selectedIndex;
  int _answerCounter;
  int _startTime;
  Timer _timer;
  Future _loadQuestion;
  var _question;

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
                Column(
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
                                visible: _answerOpacity[_answerCounter - 1],
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: ChoiceChip(
                                  label: Container(
                                    width: 100,
                                    child: AutoSizeText(
                                      _answerList[_answerCounter - 1],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                  selected: _selectedIndex == index * 2 + index2,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedIndex = index * 2 + index2;
                                    });
                                  },
                                  selectedColor: Color(0xffffc107),
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
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    children: <Widget>[
                      Divider(color: Colors.white),
                      Text(_question['topText']),
                      Column(
                        children: List.generate(
                          _question['answers'].length,
                          (index) {
                            return GestureDetector(
                              onTap: () => setSelectedText(_selectedIndex, index),
                              child: ChoiceChip(
                                label: Container(
                                  width: 150,
                                  child: AutoSizeText(
                                    _resultList[index]?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ),
                                selected: false,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(_question['bottomText']),
                    ],
                  ),
                ),
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

  void setSelectedText(int answerIndex, int resultIndex) {
    setState(() {
      _resultList[resultIndex] = _answerList[answerIndex];
      _answerOpacity[answerIndex] = false;
      _selectedIndex = null;
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
    _answerOpacity = new List(_answerList.length);
    for (int i = 0; i < _answerList.length; i++) {
      _answerOpacity[i] = true;
    }
  }

  void startNewRound() {
    _startTime = 20;
    _selectedIndex = 0;
    _answerCounter = 0;
    _loadQuestion = loadQuestionData();
    startTimer();
  }
}
