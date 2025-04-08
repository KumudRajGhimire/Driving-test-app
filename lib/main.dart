import 'package:flutter/material.dart';
import 'screens/category_selection_screen.dart';
import 'screens/quiz_type_selection_screen.dart';
import 'screens/real_exam_screen.dart'; // Import the real exam screen
import 'screens/practice_screen.dart'; // Import the practice screen
import 'screens/results_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nepal Driving Test',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Use a standard iOS blue
        primaryColor: Colors.white, // Navigation bar background
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue), // Use secondary color for accent
        scaffoldBackgroundColor: Color(0xFFF0F0F0), // Light gray background
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 17.0, color: Colors.black87), // Default body text size in iOS
          titleLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black87), // Large titles
          titleMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500, color: Colors.black87), // Medium titles
          labelLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal, color: Colors.blue), // Button text
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87, // For title and icons
          elevation: 0.5, // Subtle shadow like iOS
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: Colors.blue),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Slightly rounded buttons
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: TextStyle(fontSize: 18.0),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            side: BorderSide(color: Colors.blue),
            textStyle: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
      home: CategorySelectionScreen(), // Start with the category selection screen
      routes: {
        '/category_selection': (context) => CategorySelectionScreen(),
        '/quiz_type_selection': (context) => QuizTypeSelectionScreen(),
        '/real_exam': (context) => RealExamScreen(), // Add the route for the real exam screen
        '/practice': (context) => PracticeScreen(), // Add the route for the practice screen
        '/results': (context) => ResultsScreen(),
      },
      debugShowCheckedModeBanner: false, // Set this to false to remove the debug banner
    );
  }
}