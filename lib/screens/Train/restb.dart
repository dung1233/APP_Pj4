import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/TEST/squat_detector_view.dart';
import 'package:training_souls/screens/UI/Beginer/run.dart';

class Restb extends StatefulWidget {
  final int day;

  const Restb({Key? key, required this.day}) : super(key: key);

  @override
  State<Restb> createState() => _RestState();
}

class _RestState extends State<Restb> {
  int seconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    displayWorkoutResults();
  }

  // Trong màn hình hoặc widget muốn hiển thị kết quả
  void displayWorkoutResults() async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getAllWorkoutResults();

    // In kết quả để debug
    print("Tất cả kết quả workout: $results");

    // Xử lý và hiển thị kết quả
    for (var result in results) {
      print("ID: ${result['id']}");
      print("Ngày: ${result['day_number']}");
      print("Tên bài tập: ${result['exercise_name']}");
      print("Sets hoàn thành: ${result['sets_completed']}");
      print("Reps hoàn thành: ${result['reps_completed']}");
      print("Khoảng cách hoàn thành: ${result['distance_completed']}");
      print("Thời gian hoàn thành: ${result['duration_completed']}");
      print("Ngày hoàn thành: ${result['completed_date']}");
      print("-----------------------");
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          timer.cancel();
          goToNextScreen();
        }
      });
    });
  }

  // Trong Rest
  void goToNextScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunningTracker(day: widget.day)));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get timerText {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  // Thay CustomPainter bằng hình ảnh
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Lottie.asset(
                      'assets/img/Animation - 1743427831861.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.blue,
            child: Column(
              children: [
                // Tiến trình bài tập
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TIẾP THEO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'x 10',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Squat',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Thời gian nghỉ
                const Text(
                  'NGHỈ NGƠI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  timerText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'RobotoMono', // thêm font nếu cần
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),

                const SizedBox(height: 30),
                // Nút thêm thời gian
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white),
                    minimumSize: Size(300, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    setState(() {
                      seconds += 20;
                    });
                  },
                  child: Text(
                    '+20s',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                // Nút bỏ qua
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    minimumSize: Size(300, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    timer?.cancel();
                    goToNextScreen();
                  },
                  child: Text(
                    'BỎ QUA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
