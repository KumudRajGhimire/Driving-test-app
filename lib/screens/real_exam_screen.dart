import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RealExamScreen extends StatefulWidget {
  @override
  _RealExamScreenState createState() => _RealExamScreenState();
}

class _RealExamScreenState extends State<RealExamScreen> {
  String? category;
  List<Map<String, dynamic>> allQuestions = [];
  List<Map<String, dynamic>> currentQuizQuestions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool _isQuestionsLoaded = false;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  Timer? _timer;
  int _secondsRemaining = 15 * 60; // 15 minutes

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isQuestionsLoaded) {
      final Map<String, String> args = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
      category = args['category'];
      print('RealExamScreen - didChangeDependencies() called. Category: $category');
      _loadQuestions();
      _isQuestionsLoaded = true;
    }
  }

  Future<void> _loadQuestions() async {
    print('RealExamScreen - _loadQuestions() called for category: $category');
    String jsonString = '';
    try {
      if (category == 'A') {
        jsonString = await rootBundle.loadString('assets/data/questions_a.json');
        print('RealExamScreen - Loaded questions_a.json');
      } else if (category == 'B') {
        jsonString = await rootBundle.loadString('assets/data/questions_b.json');
      }
      if (jsonString.isNotEmpty) {
        setState(() {
          allQuestions = (json.decode(jsonString) as List).cast<Map<String, dynamic>>();
          _prepareQuiz();
        });
      }
    } catch (e) {
      print('RealExamScreen - Error loading JSON: $e');
    }
  }

  void _prepareQuiz() {
    List<Map<String, dynamic>> filteredQuestions =
    allQuestions.where((q) => q['category'] == category).toList();
    filteredQuestions.shuffle();
    currentQuizQuestions = filteredQuestions.take(20).toList();
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _showDiscardConfirmation(context, isTimeout: true);
        }
      });
    });
  }

  Future<bool> _onWillPop() async {
    return await _showDiscardConfirmation(context) ?? false;
  }

  Future<bool?> _showDiscardConfirmation(BuildContext context, {bool isTimeout = false}) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isTimeout ? 'Exam Timed Out' : 'Discard Exam?'),
          content: Text(isTimeout ? 'Your exam time has run out. Your progress will be discarded.' : 'If you go back now, your current exam progress will be discarded. Are you sure?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop(true);
                    Navigator.pushReplacementNamed(context, '/category_selection');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Leave'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Stay'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _navigateToResults() {
    Navigator.pushReplacementNamed(
      context,
      '/results',
      arguments: {'score': score, 'questions': currentQuizQuestions},
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;
    setState(() => _selectedAnswerIndex = index);
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex != null) {
      setState(() {
        _isAnswered = true;
        currentQuizQuestions[currentQuestionIndex]['userAnswerIndex'] = _selectedAnswerIndex;
      });
      if (_selectedAnswerIndex == currentQuizQuestions[currentQuestionIndex]['correctAnswerIndex']) {
        setState(() => score++);
      }
      if (currentQuestionIndex == currentQuizQuestions.length - 1) {
        _timer?.cancel();
        _navigateToResults();
      }
    }
  }

  void _nextQuestion() {
    if (_isAnswered) {
      setState(() {
        _selectedAnswerIndex = null;
        _isAnswered = false;
        if (currentQuestionIndex < currentQuizQuestions.length - 1) {
          currentQuestionIndex++;
        } else {
          _timer?.cancel();
          _navigateToResults();
        }
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Real Exam ($category)')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = currentQuizQuestions[currentQuestionIndex];
    final questionType = currentQuestion['type'];

    Widget questionWidget = SizedBox.shrink();
    if (questionType == 'image' && currentQuestion.containsKey('imagePath')) {
      questionWidget = Column(
        children: [
          if (currentQuestion.containsKey('questionText'))
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(currentQuestion['questionText'] as String, style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center),
            ),
          Image.asset(currentQuestion['imagePath'] as String, height: 150),
        ],
      );
    } else {
      questionWidget = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(currentQuestion['questionText'] as String, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Real Exam ($category)'),
          automaticallyImplyLeading: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(_formatTime(_secondsRemaining), style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Question ${currentQuestionIndex + 1} / ${currentQuizQuestions.length}',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                    SizedBox(height: 16.0),
                    questionWidget,
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    ...(currentQuestion['options'] as List<dynamic>)
                        .cast<String>()
                        .asMap()
                        .entries
                        .map((entry) {
                      final int index = entry.key;
                      final String option = entry.value;
                      Color? borderColor;
                      double borderWidth = 1.0;

                      if (_selectedAnswerIndex == index) {
                        borderColor = Colors.blue[800];
                        borderWidth = 3.0;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: InkWell(
                          onTap: _isAnswered ? null : () => _selectAnswer(index),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor ?? Colors.grey[600]!, width: borderWidth),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(padding: const EdgeInsets.all(12.0), child: Text(option)),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: _selectedAnswerIndex != null ? () {
                        _submitAnswer();
                        _nextQuestion();
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedAnswerIndex != null ? Colors.blue : Colors.grey,
                      ),
                      child: Text(currentQuestionIndex < currentQuizQuestions.length - 1 ? 'Next' : 'Finish'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}