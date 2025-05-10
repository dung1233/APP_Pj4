import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/TEST/squat_detector_view.dart';

class Rest extends StatefulWidget {
  final int day;

  const Rest({Key? key, required this.day}) : super(key: key);

  @override
  State<Rest> createState() => _RestState();
}

class _RestState extends State<Rest> {
  int seconds = 30;
  Timer? timer;
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Colors
  static const Color primaryColor = Color(0xFFFF6B00);
  static const Color secondaryColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadWorkoutData();
    if (mounted) {
      startTimer();
    }
  }

  Future<void> _loadWorkoutData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final results = await _dbHelper.getAllWorkoutResults();
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
    timer?.cancel(); // Clear any existing timer
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
    if (_isLoading || !mounted) return;

    timer?.cancel(); // Clear timer before navigation
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SquatDetectorView(day: widget.day),
      ),
    );
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
                      fit: BoxFit.cover,
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
                const SizedBox(height: 30),
                Text(
                  'Nghỉ Ngơi',
                  style: GoogleFonts.urbanist(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  timerText,
                  style: const TextStyle(
                    color: secondaryColor,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),
                const SizedBox(height: 60),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
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
                    minimumSize: const Size(300, 50),
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
