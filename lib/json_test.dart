import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Unit 2  0/6 Lessons'),
        backgroundColor: Colors.purple[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visiting Museums and Galleries',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "You'll learn about visiting museums and galleries while using quantity determiners.",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildLessonItem(
                      Icons.mic, 'Be Clear: Museum Names', 'Pronunciation'),
                  buildLessonItem(Icons.graphic_eq, 'Galleries', 'Word Stress'),
                  buildLessonItem(
                      Icons.mic, 'Say it Well: Art Supplies', 'Pronunciation'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLessonItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 28),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
