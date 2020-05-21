class Question {
  String questionText;
  String topText;
  String bottomText;
  Map<String, num> answers;
  List<double> answerOpacity;

  Question(this.questionText, this.topText, this.bottomText, this.answers) {
    answerOpacity = new List(answers.length);
    for (int i = 0; i < answerOpacity.length; i++) {
      answerOpacity[i] = 1.0;
    }
  }
}
