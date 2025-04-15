import 'package:flutter/material.dart';
import 'package:training_souls/screens/TEST/squat_detector_view.dart';

class CompletionScreen extends StatelessWidget {
  final String message;
  final VoidCallback onContinue;

  const CompletionScreen({
    Key? key,
    required this.message,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Hoàn thành"),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.greenAccent.shade400, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SquatDetectorView(),
                      ),
                    );
                  },
                  child: const Text(
                    "Tiếp tục",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
