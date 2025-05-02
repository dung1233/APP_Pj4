import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/TEST/squat_detector_view.dart';
import 'package:training_souls/screens/UI/Beginer/run.dart';
import 'package:training_souls/screens/UI/Beginer/situp.dart';

class Restc extends StatefulWidget {
  final int day;

  const Restc({Key? key, required this.day}) : super(key: key);

  @override
  State<Restc> createState() => _RestState();
}

class _RestState extends State<Restc> {
  int seconds = 30;
  Timer? timer;
  bool _isLoading = false; // Thêm biến kiểm soát trạng thái loading

  @override
  void initState() {
    super.initState();
    startTimer();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final dbHelper = DatabaseHelper();
      final results = await dbHelper.getAllWorkoutResults();

      // Debug log
      debugPrint("Workout results: $results");
    } catch (e) {
      debugPrint("Error loading workout data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          timer.cancel();
          _goToNextScreen();
        }
      });
    });
  }

  Future<void> _goToNextScreen() async {
    if (_isLoading) return; // Ngăn chặn chuyển trang khi đang loading

    if (!mounted) return;

    // Thêm delay nhỏ để đảm bảo animation hoàn tất
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    await initializeCameras();
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

  Color primaryColor = Color(0xFFFF6B00); // Cam sáng hiện đại
  Color secondaryColor = Color(0xFF333333); // Màu nền hoặc chữ phụ
  Color backgroundColor = Color(0xFFF5F5F5); // Màu nền nhẹ

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/img/dayoff.jpg',

                      // Thêm frame rate cố định
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '',
                          style: GoogleFonts.urbanist(
                            color: secondaryColor,
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
                            '',
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
                Text(
                  'Nghỉ  Ngơi',
                  style: GoogleFonts.urbanist(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  timerText,
                  style: TextStyle(
                    color: secondaryColor,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),
                const SizedBox(height: 60),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                    minimumSize: Size(300, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() => seconds += 20);
                    }
                  },
                  child: Text(
                    '+20s',
                    style: GoogleFonts.urbanist(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    timer?.cancel();
                    _goToNextScreen();
                  },
                  child: Text(
                    'BỎ QUA',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
