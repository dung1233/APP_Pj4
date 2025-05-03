import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:training_souls/screens/Train/train_screen.dart'; // cần nếu bạn gọi trực tiếp Hive

class CompletionScreend extends StatelessWidget {
  final String message;
  final VoidCallback onContinue;

  const CompletionScreend({
    Key? key,
    required this.message,
    required this.onContinue,
  }) : super(key: key);

  static Future<String?> getToken() async {
    var box = await Hive.openBox('userBox');
    return box.get('token');
  }

  Future<void> _sendWorkoutResults(BuildContext context) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không tìm thấy token")),
      );
      return;
    }

    final url = Uri.parse(
        'http://54.251.220.228:8080/trainingSouls/workout/workout-results');

    final Map<String, dynamic> data = {
      "dayNumber": 1,
      "results": [
        {
          "exerciseName": "Squat",
          "setsCompleted": 1,
          "repsCompleted": 2,
          "distanceCompleted": 0.0,
          "durationCompleted": 0
        },
        {
          "exerciseName": "Gập bụng",
          "setsCompleted": 1,
          "repsCompleted": 2,
          "distanceCompleted": 0.0,
          "durationCompleted": 0
        },
        {
          "exerciseName": "Hít đất",
          "setsCompleted": 1,
          "repsCompleted": 2,
          "distanceCompleted": 0.0,
          "durationCompleted": 0
        },
        {
          "exerciseName": "Chạy bộ",
          "setsCompleted": 0,
          "repsCompleted": 0,
          "distanceCompleted": 2.0,
          "durationCompleted": 16
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Gửi dữ liệu thành công")),
        );

        onContinue();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("❌ Lỗi: ${response.statusCode} - ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi gửi dữ liệu: $e")),
      );
    }
  }

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
                onPressed: () => _sendWorkoutResults(context),
                child: const Text("Hoàn Thành"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
