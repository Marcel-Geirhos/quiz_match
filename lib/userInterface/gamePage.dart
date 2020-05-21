import 'package:flutter/material.dart';
import 'package:quiz_match/models/question.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _selectedIndex = 0;
  Question _question;
  var _answerList;
  List<String> _resultList;

  @override
  void initState() {
    super.initState();
    _question = Question('Welche Technologie Unternehmen haben die höchste Marktkapitalisierung?', 'Höchste',
        'Niedrigste', {'Alphabet': 5, 'Facebook': 2, 'Amazon': 3});
    _answerList = _question.answers.entries.toList();
    _resultList = new List(_question.answers.length);
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
      body: Column(
        children: <Widget>[
          Text(
            _question.questionText,
            textAlign: TextAlign.center,
          ),
          Column(
            children: List.generate(_question.answers.length, (index) {
              return Opacity(
                opacity: _question.answerOpacity[index],
                child: ChoiceChip(
                  label: Text(_answerList[index].key),
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
          Text(_question.topText),
          Column(
            children: List.generate(_question.answers.length, (index) {
              return GestureDetector(
                onTap: () => setSelectedText(_selectedIndex, index),
                child: ChoiceChip(
                  label: Text(_resultList[index]?.toString() ?? ''),
                  selected: false,
                ),
              );
            }),
          ),
          Text(_question.bottomText),
        ],
      ),
    );
  }

  void setSelectedText(int selectedIndex, int index) {
    setState(() {
      _resultList[index] = _answerList[selectedIndex].key;
      _question.answerOpacity[index] = 0.0;
      _selectedIndex = null;
    });
  }
}
