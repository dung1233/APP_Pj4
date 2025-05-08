import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:intl/intl.dart';
import 'package:training_souls/screens/trainhome.dart';

class Ol extends StatefulWidget {
  const Ol({super.key});

  @override
  State<StatefulWidget> createState() => _OlViewState();
}

late final ApiService apiService;

class _OlViewState extends State<Ol> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _results = [];
  Map<String, dynamic> _userProfile = {};
  late final ApiService apiService; // Chuyển vào trong class

  @override
  void initState() {
    super.initState();

    final dio = Dio();
    apiService = ApiService(dio);

    displayWorkoutResults();
    _printDatabaseContent(dbHelper);
    _loadUserProfile(dbHelper);
  }

  void displayWorkoutResults() async {
    try {
      var box = await Hive.openBox('userBox');
      final token = box.get('token');

      if (token == null) {
        throw Exception("Token không tồn tại, vui lòng đăng nhập lại");
      }

      final workouts = await apiService.getWorkoutHistory("Bearer $token");
      print("🎯 Dữ liệu trả về từ API:");
      for (var w in workouts) {
        print(w.toJson());
      }
      setState(() {
        _results = workouts.map((w) => w.toJson()).toList();
      });
    } catch (e) {
      print("❌ Lỗi khi gọi API workout history: $e");
    }
  }

  Future<void> _printDatabaseContent(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;

    // Lấy và in thông tin user_profile
    final userProfiles = await db.query('user_profile');
    print("❓ Dữ liệu bảng user_profile:");
    userProfiles.forEach((profile) {
      print(profile);
    });
  }

  Future<void> _loadUserProfile(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;
    final profiles = await db.query('user_profile');
    if (profiles.isNotEmpty) {
      setState(() {
        _userProfile = profiles.first;
      });
    }
  }

  // Trong màn hình hoặc widget muốn hiển thị kết quả

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Trainhome()),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    Text(
                      'Activity',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        displayWorkoutResults();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Đẩy lên cao hơn
              Center(
                child: ActivityRingsWidget(
                  strength: _userProfile['strength'] ?? 0,
                  agility: _userProfile['agility'] ?? 0,
                  endurance: _userProfile['endurance'] ?? 0,
                  health: _userProfile['health'] ?? 0,
                ),
              ),
              const SizedBox(height: 30), // Khoảng cách giữa hai phần
              WorkoutsWidget(results: _results),
              const SizedBox(height: 20), // Khoảng cách trước phần Awards
              AwardsWidget(),
            ],
          ),
        ],
      ),
    ); // ✅ thêm dấu ;
  }
}

class ActivityRingsWidget extends StatelessWidget {
  final int strength;
  final int agility;
  final int endurance;
  final int health;

  const ActivityRingsWidget({
    super.key,
    required this.strength,
    required this.agility,
    required this.endurance,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    final int maxStat = 100;
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
                      _buildStatText("Strength", strength, Colors.red),
                      _buildStatText("Agility", agility, Colors.yellow),
                      _buildStatText("Endurance", endurance, Colors.blue),
                      _buildStatText("Health", health, Colors.green),
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
                        strength / maxStat,
                        agility / maxStat,
                        endurance / maxStat,
                        health / maxStat,
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
          Text(title,
              style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16)),
          const SizedBox(width: 8),
          Text(value,
              style: GoogleFonts.urbanist(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatText(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.urbanist(color: Colors.white, fontSize: 14)),
          const SizedBox(width: 8),
          Text("$value",
              style: GoogleFonts.urbanist(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ActivityRingPainter extends CustomPainter {
  final double strengthProgress;
  final double agilityProgress;
  final double enduranceProgress;
  final double healthProgress;

  ActivityRingPainter(
    this.strengthProgress,
    this.agilityProgress,
    this.enduranceProgress,
    this.healthProgress,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawRing(canvas, center, radius - 10, Colors.red, strengthProgress);
    _drawRing(canvas, center, radius - 20, Colors.yellow, agilityProgress);
    _drawRing(canvas, center, radius - 30, Colors.blue, enduranceProgress);
    _drawRing(canvas, center, radius - 40, Colors.green, healthProgress);
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
  final List<Map<String, dynamic>> results;

  const WorkoutsWidget({super.key, required this.results});

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
                  style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text("Show More",
                  style:
                      GoogleFonts.urbanist(color: Colors.green, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...results.map((r) {
          final name = (r['exerciseName'] ?? '').toString().toLowerCase();
          final isRun = name.contains('run') || name.contains('chạy');
          String value;

          if (isRun) {
            // Xử lý cho bài tập chạy bộ
            final rawDistance = (r['distanceCompleted'] ?? 0.0);
            final rawDuration = (r['durationCompleted'] ?? 0.0);

            value = "$rawDistance m - $rawDuration p";
          } else {
            // Xử lý cho các bài tập khác
            value =
                "${r['setsCompleted'] ?? 0} sets - ${r['repsCompleted'] ?? 0} reps";
          }

          // Xử lý ngày hoàn thành
          String day = r['completionDate'] ?? 'Hôm nay';

          return WorkoutCard(
            title: r['exerciseName'] ?? 'No Name',
            value: value,
            day: day,
          );
        }),
      ],
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title;
  final String value;
  final String day;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.value,
    required this.day,
  });
  String _formatDate(String raw) {
    try {
      final date = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(Icons.fitness_center, color: Colors.green),
          title: Text(title,
              style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16)),
          subtitle: Text(value,
              style: GoogleFonts.urbanist(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          trailing: Text(_formatDate(day),
              style: GoogleFonts.urbanist(color: Colors.grey, fontSize: 14)),
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
                  style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text("Show More",
                  style:
                      GoogleFonts.urbanist(color: Colors.green, fontSize: 16)),
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
              style: GoogleFonts.urbanist(color: Colors.white, fontSize: 14)),
          Text(award["subtitle"]!,
              style: GoogleFonts.urbanist(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
