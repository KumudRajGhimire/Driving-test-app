import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? resultsData =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int? score = resultsData?['score'] as int?;
    final List<Map<String, dynamic>>? questions =
    resultsData?['questions'] as List<Map<String, dynamic>>?;
    final int totalQuestions = questions?.length ?? 0;
    final bool passed = score != null && totalQuestions == 20 && score >= 10;
    final Color scoreColor = passed ? Colors.green : Colors.red;
    final String statusText = passed ? 'Passed!' : 'Failed!';

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Your Score:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                score != null ? '$score / $totalQuestions' : 'N/A',
                style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: scoreColor),
              ),
            ),
            SizedBox(height: 10.0),
            if (score != null && totalQuestions == 20)
              Align(
                alignment: Alignment.center,
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: scoreColor),
                ),
              ),
            SizedBox(height: 30.0),
            if (questions != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detailed Breakdown:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10.0),
              for (var i = 0; i < questions.length; i++) ...[
                Text(
                  '${i + 1}. ${questions[i]['questionText']}',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5.0),
                if (questions[i].containsKey('userAnswerIndex') &&
                    questions[i]['userAnswerIndex'] != questions[i]['correctAnswerIndex'])
                  Text(
                    'Your Answer: ${(questions[i]['options'] as List<dynamic>)[questions[i]['userAnswerIndex']]}',
                    style: TextStyle(fontSize: 16.0, color: Colors.red[700]),
                  ),
                Text(
                  'Correct Answer: ${(questions[i]['options'] as List<dynamic>)[questions[i]['correctAnswerIndex']]}',
                  style: TextStyle(fontSize: 16.0, color: Colors.green[700]),
                ),
                SizedBox(height: 15.0),
              ],
            ],
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/category_selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Go Back to Category Selection'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                final String? category = (resultsData?['questions'] as List<Map<String, dynamic>>?)?.first['category'] as String?;
                if (category != null) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/quiz_type_selection',
                    arguments: category,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Category not found.')),
                  );
                }
              },
              child: Text('Retake New Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}