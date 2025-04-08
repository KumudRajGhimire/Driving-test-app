import 'package:flutter/material.dart';
import 'real_exam_screen.dart';
import 'practice_screen.dart';

class QuizTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? category = ModalRoute.of(context)?.settings.arguments as String?;

    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Category not provided.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Quiz Type ($category)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/real_exam',
                  arguments: {'category': category},
                );
              },
              child: Image.asset(
                'assets/images/exam.png', // Replace with your actual image path if different
                height: 300, // Adjust height as needed
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/practice',
                  arguments: {'category': category},
                );
              },
              child: Image.asset(
                'assets/images/practice.png', // Replace with your actual image path if different
                height: 300, // Adjust height as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}