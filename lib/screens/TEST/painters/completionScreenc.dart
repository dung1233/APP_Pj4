import 'package:flutter/material.dart';
import 'package:training_souls/screens/TEST/squat_detector_view.dart';
import 'package:training_souls/screens/UI/Beginer/run.dart';
import 'package:training_souls/screens/UI/Beginer/situp.dart';

class CompletionScreenc extends StatelessWidget {
  final String message;
  final VoidCallback onContinue;

  const CompletionScreenc({
    Key? key,
    required this.message,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hoàn thành")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("✅", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RunningTracker()));
                },
                child: const Text("Tiếp tục"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
