import 'dart:math';

import 'package:flutter/material.dart';
import 'package:training_souls/data/DatabaseHelper.dart';

class Ol extends StatefulWidget {
  const Ol({super.key});

  @override
  State<StatefulWidget> createState() => _OlViewState();
}

class _OlViewState extends State<Ol> {
  List<Map<String, dynamic>> workoutResults = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    displayWorkoutResults();
  }

  // Trong màn hình hoặc widget muốn hiển thị kết quả
  void displayWorkoutResults() async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getAllWorkoutResults();

    setState(() {
      workoutResults = results;
      isLoading = false; // Dòng này cực kỳ quan trọng!
    });
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 8),
                  child: Text(
                    'Acivity',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20), // Đẩy lên cao hơn
                Center(
                  child: ActivityRingsWidget(
                    moveProgress: 171 / 270,
                    exerciseProgress: 26 / 30,
                    standProgress: 4 / 12,
                  ),
                ),
                const SizedBox(height: 30), // Khoảng cách giữa hai phần
                WorkoutsWidget(
                    workoutResults: workoutResults, isLoading: isLoading),
                const SizedBox(height: 20), // Khoảng cách trước phần Awards
                AwardsWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityRingsWidget extends StatelessWidget {
  final double moveProgress;
  final double exerciseProgress;
  final double standProgress;

  const ActivityRingsWidget({
    super.key,
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 350,
          height: 170,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 26, 25, 25),
            borderRadius: BorderRadius.circular(20), // Bo tròn viền
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      _buildActivityText(
                          "Move",
                          "${(moveProgress * 270).toInt()}/270 CAL",
                          Colors.red),
                      _buildActivityText(
                          "Exercise",
                          "${(exerciseProgress * 30).toInt()}/30 MIN",
                          Colors.green),
                      _buildActivityText(
                          "Stand",
                          "${(standProgress * 12).toInt()}/12 HRS",
                          Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(150, 150),
                      painter: ActivityRingPainter(
                        moveProgress,
                        exerciseProgress,
                        standProgress,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityText(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ActivityRingPainter extends CustomPainter {
  final double moveProgress;
  final double exerciseProgress;
  final double standProgress;

  ActivityRingPainter(
      this.moveProgress, this.exerciseProgress, this.standProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawRing(canvas, center, radius - 10, Colors.red, moveProgress);
    _drawRing(canvas, center, radius - 20, Colors.green, exerciseProgress);
    _drawRing(canvas, center, radius - 30, Colors.blue, standProgress);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, Color color,
      double progress) {
    final Paint backgroundPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class WorkoutsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> workoutResults;
  final bool isLoading;

  const WorkoutsWidget({
    super.key,
    required this.workoutResults,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Workouts",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text("Show More",
                  style: TextStyle(color: Colors.green, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          Center(child: CircularProgressIndicator(color: Colors.green))
        else if (workoutResults.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No workouts available",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          )
        else
          Column(
            children: workoutResults.map((workout) {
              // Lấy dữ liệu từ workout để hiển thị
              String title = workout["exercise_name"] ?? "Unknown";
              int sets = workout["sets_completed"] ?? 0;
              int reps = workout["reps_completed"] ?? 0;

              // Định dạng ngày hoàn thành
              String completedDate = workout["completed_date"] ?? "";
              String displayDate = "Today"; // Mặc định hiển thị "Today"

              if (completedDate.isNotEmpty) {
                try {
                  final date = DateTime.parse(completedDate);
                  final now = DateTime.now();
                  final difference = now.difference(date).inDays;

                  if (difference == 0) {
                    displayDate = "Today";
                  } else if (difference == 1) {
                    displayDate = "Yesterday";
                  } else {
                    // Hiển thị tên của ngày trong tuần
                    List<String> weekdays = [
                      "Monday",
                      "Tuesday",
                      "Wednesday",
                      "Thursday",
                      "Friday",
                      "Saturday",
                      "Sunday"
                    ];
                    displayDate = weekdays[
                        date.weekday - 1]; // weekday bắt đầu từ 1 (Monday)
                  }
                } catch (e) {
                  print("Error parsing date: $e");
                  displayDate = "Recently";
                }
              }

              return WorkoutCard({
                "title": title,
                "value": "$sets sets × $reps reps",
                "day": displayDate,
              });
            }).toList(),
          ),
      ],
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final Map<String, String> workout;

  const WorkoutCard(this.workout, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(Icons.fitness_center, color: Colors.green),
          title: Text(workout["title"]!,
              style: TextStyle(color: Colors.white, fontSize: 16)),
          subtitle: Text(workout["value"]!,
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          trailing: Text(workout["day"]!,
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      ),
    );
  }
}

class AwardsWidget extends StatelessWidget {
  final List<Map<String, String>> awards = [
    {"title": "August Challenge", "subtitle": "2020"},
    {"title": "Perfect Week (Stand)", "subtitle": "103"},
    {"title": "National Parks Challenge", "subtitle": "8/30/20"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Awards",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text("Show More",
                  style: TextStyle(color: Colors.green, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: awards.map((award) => AwardCard(award)).toList(),
          ),
        ),
      ],
    );
  }
}

class AwardCard extends StatelessWidget {
  final Map<String, String> award;

  const AwardCard(this.award, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: Colors.yellow, size: 50),
          const SizedBox(height: 5),
          Text(award["title"]!,
              style: TextStyle(color: Colors.white, fontSize: 14)),
          Text(award["subtitle"]!,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
