import 'package:flutter/material.dart';
import 'quiz_type_selection_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Which exam are you preparing for?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 8.0),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/quiz_type_selection', arguments: 'A');
                  },
                  child: Image.asset(
                    'assets/images/two.png',
                    height: 300,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30), // Add some spacing between the two categories
            Column(
              children: <Widget>[
                SizedBox(height: 8.0),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/quiz_type_selection', arguments: 'B');
                  },
                  child: Image.asset(
                    'assets/images/four.png',
                    height: 300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}