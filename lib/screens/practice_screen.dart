import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PracticeScreen extends StatefulWidget {
  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String? category;
  List<Map<String, dynamic>> allQuestions = [];
  List<Map<String, dynamic>> currentQuestion = []; // Will hold a list of one question
  int questionNumber = 1;
  int score = 0;
  bool _isQuestionsLoaded = false;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  Random _random = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isQuestionsLoaded) {
      final Map<String, String> args = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
      category = args['category'];
      print('PracticeScreen - didChangeDependencies() called. Category: $category');
      _loadQuestions();
      _isQuestionsLoaded = true;
    }
  }

  Future<void> _loadQuestions() async {
    print('PracticeScreen - _loadQuestions() called for category: $category');
    String jsonString = '';
    try {
      if (category == 'A') {
        jsonString = await rootBundle.loadString('assets/data/questions_a.json');
        print('PracticeScreen - Loaded questions_a.json');
      } else if (category == 'B') {
        jsonString = await rootBundle.loadString('assets/data/questions_b.json');
        print('PracticeScreen - Loaded questions_b.json');
      } else {
        print('PracticeScreen - Unknown category: $category');
      }

      if (jsonString.isNotEmpty) {
        setState(() {
          allQuestions = (json.decode(jsonString) as List).cast<Map<String, dynamic>>();
          _getNextQuestion(); // Load the first question
        });
      }
    } catch (e) {
      print('PracticeScreen - Error loading JSON: $e');
    }
  }

  void _getNextQuestion() {
    if (allQuestions.isNotEmpty) {
      final filteredQuestions = allQuestions.where((q) => q['category'] == category).toList();
      if (filteredQuestions.isNotEmpty) {
        final randomIndex = _random.nextInt(filteredQuestions.length);
        setState(() {
          currentQuestion = [filteredQuestions[randomIndex]];
          _selectedAnswerIndex = null;
          _isAnswered = false;
        });
      } else {
        // Handle case where no questions are left for the category (shouldn't happen if JSON is loaded)
        print('PracticeScreen - No questions left for category: $category');
      }
    }
  }

  void _selectAnswer(int index) {
    if (_isAnswered || currentQuestion.isEmpty) {
      return;
    }
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });

    final correctAnswerIndex = currentQuestion[0]['correctAnswerIndex'] as int;
    if (index == correctAnswerIndex) {
      setState(() {
        score++;
      });
      print('PracticeScreen - Correct answer! Score: $score');
    } else {
      print('PracticeScreen - Incorrect answer.');
    }
  }

  void _nextQuestion() {
    setState(() {
      questionNumber++;
    });
    _getNextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Practice ($category)'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = currentQuestion[0];
    final questionType = question['type'];
    final correctAnswerIndex = question['correctAnswerIndex'] as int;

    Widget questionWidget = SizedBox.shrink();

    if (questionType == 'image' && question.containsKey('imagePath')) {
      questionWidget = Column(
        children: [
          if (question.containsKey('questionText'))
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                question['questionText'] as String,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
          Image.asset(
            question['imagePath'] as String,
            height: 150,
          ),
        ],
      );
    } else {
      questionWidget = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          question['questionText'] as String,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice ($category)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded( // For the question area
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Question $questionNumber',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  questionWidget,
                ],
              ),
            ),
            Expanded( // For the options and button area
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 30.0),
                  ...(question['options'] as List<dynamic>)
                      .cast<String>()
                      .asMap()
                      .entries
                      .map((entry) {
                    final int index = entry.key;
                    final String option = entry.value;
                    Color? borderColor;
                    double borderWidth = 1.0;

                    if (_isAnswered) {
                      if (index == correctAnswerIndex) {
                        borderColor = Colors.green[700];
                        borderWidth = 3.0;
                      } else if (index == _selectedAnswerIndex && index != correctAnswerIndex) {
                        borderColor = Colors.red[700];
                        borderWidth = 3.0;
                      }
                    } else if (_selectedAnswerIndex == index) {
                      borderColor = Colors.blue[800];
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: InkWell(
                        onTap: _isAnswered ? null : () {
                          _selectAnswer(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: borderColor ?? Colors.grey[600]!,
                              width: borderWidth,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(option),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: _isAnswered ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAnswered ? Colors.blue : Colors.grey,
                    ),
                    child: Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}