import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/api/api_client.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:intl/intl.dart';
import 'package:training_souls/screens/trainhome.dart';
import 'package:training_souls/api/user_service.dart';
import 'package:training_souls/models/user_response.dart';

import '../../data/local_storage.dart';

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
  Map<String, dynamic> _userInfo = {};
  double _powerLevel = 0.0;
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
    try {
      // First ensure database tables exist
      await dbHelper.checkAndCreateTables();

      // Try to fetch data from API first
      final token = await LocalStorage.getValidToken();
      if (token != null) {
        final dio = Dio();
        dio.options.baseUrl = 'http://54.251.220.228:8080/trainingSouls';
        dio.options.headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        try {
          print("📡 Fetching data from API...");
          final response = await dio.get('/users/getMyInfo');

          if (response.data['code'] == 0 && response.data['result'] != null) {
            print("✅ API data received successfully");
            final userData = response.data['result'];
            final userProfile = userData['userProfile'];
            final totalScore =
                (userData['totalScore'] as num?)?.toDouble() ?? 0.0;

            // Update state with fresh API data
            setState(() {
              _powerLevel = totalScore;

              _userInfo = {
                'userID': userData['userID'],
                'name': userData['name'] ?? '',
                'email': userData['email'] ?? '',
                'accountType': userData['accountType'] ?? 'basic',
                'points': userData['points'] ?? 0,
                'level': userData['level'] ?? 1,
                'totalScore': totalScore
              };

              if (userProfile != null) {
                _userProfile = {
                  'userID': userData['userID'],
                  'gender': userProfile['gender'] ?? '',
                  'age': userProfile['age'] ?? 0,
                  'height': userProfile['height'] ?? 0,
                  'weight': userProfile['weight'] ?? 0,
                  'bmi': userProfile['bmi'] ?? 0.0,
                  'bodyFatPercentage': userProfile['bodyFatPercentage'] ?? 0.0,
                  'muscleMassPercentage':
                      userProfile['muscleMassPercentage'] ?? 0.0,
                  'level': userProfile['level'] ?? 'Beginner',
                  'strength': userProfile['strength'] ?? 0,
                  'deathPoints': userProfile['deathPoints'] ?? 0,
                  'agility': userProfile['agility'] ?? 0,
                  'endurance': userProfile['endurance'] ?? 0,
                  'health': userProfile['health'] ?? 0,
                };
              } else {
                _userProfile = {
                  'strength': 0,
                  'agility': 0,
                  'endurance': 0,
                  'health': 0,
                  'level': 'Beginner',
                };
              }
            });

            // After successfully getting API data, update local database as backup
            try {
              await dbHelper.insertUserInfo(_userInfo);
              if (userProfile != null) {
                await dbHelper.insertUserProfile(_userProfile);
              }
              print("✅ Local database updated with latest API data");
            } catch (dbError) {
              print("⚠️ Failed to update local database: $dbError");
            }
          } else {
            throw Exception("Invalid API response format");
          }
        } catch (apiError) {
          print("❌ API error: $apiError");
          print("⚠️ Falling back to local database...");

          // Only use local database if API completely fails
          final db = await dbHelper.database;
          try {
            final userInfos = await db.query('user_info');
            final profiles = await db.query('user_profile');

            if (userInfos.isNotEmpty) {
              setState(() {
                _userInfo = userInfos.first;
                _powerLevel =
                    (userInfos.first['totalScore'] as num?)?.toDouble() ?? 0.0;
                if (profiles.isNotEmpty) {
                  _userProfile = profiles.first;
                }
              });
              print("✅ Loaded data from local database");
            } else {
              throw Exception("No data in local database");
            }
          } catch (dbError) {
            print("❌ Local database error: $dbError");
            throw dbError;
          }
        }
      } else {
        throw Exception("No valid token found");
      }
    } catch (e) {
      print("❌ Fatal error in _loadUserProfile: $e");
      // If both API and local database fail, show error state
      setState(() {
        _powerLevel = 0.0;
        _userInfo = {
          'accountType': 'basic',
          'name': 'Unknown',
          'totalScore': 0.0
        };
        _userProfile = {
          'strength': 0,
          'agility': 0,
          'endurance': 0,
          'health': 0,
          'level': 'Beginner',
        };
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
                      'Hoạt Động',
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
                      _buildStatText("Sức Mạnh", strength, Colors.red),
                      _buildStatText("Tốc Độ", agility, Colors.yellow),
                      _buildStatText("Sức Bền", endurance, Colors.blue),
                      _buildStatText("Máu", health, Colors.green),
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

  // Hàm nhóm các bài tập theo ngày
  Map<String, List<Map<String, dynamic>>> _groupWorkoutsByDate() {
    Map<String, List<Map<String, dynamic>>> groupedWorkouts = {};

    for (var workout in results) {
      String date = workout['completionDate'] ?? workout['createdAt'];
      try {
        final DateTime workoutDate = DateTime.parse(date);
        String formattedDate = DateFormat('dd/MM/yyyy').format(workoutDate);

        if (!groupedWorkouts.containsKey(formattedDate)) {
          groupedWorkouts[formattedDate] = [];
        }
        groupedWorkouts[formattedDate]!.add(workout);
      } catch (e) {
        print("Lỗi khi parse ngày: $e");
      }
    }

    // Sắp xếp các ngày theo thứ tự mới nhất lên đầu
    var sortedDates = groupedWorkouts.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd/MM/yyyy').parse(a);
        final dateB = DateFormat('dd/MM/yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    Map<String, List<Map<String, dynamic>>> sortedWorkouts = {};
    for (var date in sortedDates) {
      sortedWorkouts[date] = groupedWorkouts[date]!;
    }

    return sortedWorkouts;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final groupedWorkouts = _groupWorkoutsByDate();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 25, 25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center,
                        color: Colors.green, size: screenWidth * 0.06),
                    SizedBox(width: screenWidth * 0.02),
                    Text("Lịch sử tập luyện",
                        style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward,
                      color: Colors.green, size: screenWidth * 0.05),
                  label: Text("Xem thêm",
                      style: GoogleFonts.urbanist(
                          color: Colors.green,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          SizedBox(height: screenWidth * 0.02),
          ...groupedWorkouts.entries.map((entry) {
            return WorkoutDateGroup(
              date: entry.key,
              workouts: entry.value,
            );
          }),
          SizedBox(height: screenWidth * 0.02),
        ],
      ),
    );
  }
}

class WorkoutDateGroup extends StatelessWidget {
  final String date;
  final List<Map<String, dynamic>> workouts;

  const WorkoutDateGroup({
    super.key,
    required this.date,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          collapsedIconColor: Colors.grey,
          iconColor: Colors.green,
          title: Row(
            children: [
              Icon(Icons.calendar_today,
                  color: Colors.green, size: screenWidth * 0.05),
              SizedBox(width: screenWidth * 0.02),
              Text(
                date,
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenWidth * 0.005,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${workouts.length} bài tập",
                  style: GoogleFonts.urbanist(
                    color: Colors.green,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
          children: workouts.map((workout) {
            final name =
                (workout['exerciseName'] ?? '').toString().toLowerCase();
            final isRun = name.contains('run') || name.contains('chạy');
            String value;
            IconData icon;

            if (isRun) {
              icon = Icons.directions_run;
              final rawDistance = (workout['distanceCompleted'] ?? 0.0);
              final rawDuration = (workout['durationCompleted'] ?? 0.0);
              value = "${rawDistance.toStringAsFixed(2)} km - $rawDuration p";
            } else {
              icon = Icons.fitness_center;
              value =
                  "${workout['setsCompleted'] ?? 0} sets - ${workout['repsCompleted'] ?? 0} reps";
            }

            return Container(
              margin: EdgeInsets.only(
                left: screenWidth * 0.08,
                right: screenWidth * 0.04,
                bottom: screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.01,
                ),
                leading: Container(
                  padding: EdgeInsets.all(screenWidth * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      color: Colors.green, size: screenWidth * 0.045),
                ),
                title: Text(
                  workout['exerciseName'] ?? 'No Name',
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(top: screenWidth * 0.01),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.urbanist(
                      color: Colors.green,
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AwardsWidget extends StatefulWidget {
  const AwardsWidget({super.key});

  @override
  State<AwardsWidget> createState() => _AwardsWidgetState();
}

class _AwardsWidgetState extends State<AwardsWidget> {
  final List<Map<String, dynamic>> awards = [
    {
      "title": "Điểm danh 3 ngày",
      "subtitle": "Nhận 50 điểm",
      "icon": Icons.calendar_today,
      "color": Colors.blue,
      "points": 50,
      "days": 3
    },
    {
      "title": "Điểm danh 7 ngày",
      "subtitle": "Nhận 100 điểm",
      "icon": Icons.calendar_month,
      "color": Colors.green,
      "points": 100,
      "days": 7
    },
    {
      "title": "Điểm danh 30 ngày",
      "subtitle": "Nhận 500 điểm",
      "icon": Icons.calendar_view_month,
      "color": Colors.purple,
      "points": 500,
      "days": 30
    },
    {
      "title": "Streak 3 ngày",
      "subtitle": "Nhận 100 điểm",
      "icon": Icons.local_fire_department,
      "color": Colors.orange,
      "points": 100,
      "days": 3
    },
    {
      "title": "Streak 7 ngày",
      "subtitle": "Nhận 300 điểm",
      "icon": Icons.local_fire_department,
      "color": Colors.red,
      "points": 300,
      "days": 7
    },
  ];

  bool _isLoading = false;
  bool _isRewardLoading = false;
  String _checkInStatus = "Chưa điểm danh hôm nay";
  int _currentStreak = 0;
  int _totalPoints = 0;
  final ApiService _apiService = ApiClient().service;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    try {
      var box = await Hive.openBox('userBox');
      final token = box.get('token');
      if (token == null) return;

      // Không có API status, sử dụng dữ liệu local
      setState(() {
        _currentStreak = box.get('currentStreak') ?? 0;

        // Kiểm tra xem đã điểm danh hôm nay chưa
        final lastCheckIn = box.get('lastCheckIn');
        if (lastCheckIn != null) {
          final today = DateTime.now().toIso8601String().split('T').first;
          _checkInStatus = lastCheckIn == today
              ? "Đã điểm danh hôm nay"
              : "Chưa điểm danh hôm nay";
        } else {
          _checkInStatus = "Chưa điểm danh hôm nay";
        }
      });
    } catch (e) {
      print("❌ Lỗi khi tải trạng thái người dùng: $e");
    }
  }

  Future<void> _handleCheckIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var box = await Hive.openBox('userBox');
      final token = box.get('token');
      if (token == null) throw Exception("Token không tồn tại");

      final response = await _apiService.postCheckIn("Bearer $token");

      if (response.contains("thành công")) {
        // Lưu lại ngày điểm danh
        box.put(
            'lastCheckIn', DateTime.now().toIso8601String().split('T').first);

        // Cập nhật streak
        int streak = box.get('currentStreak') ?? 0;
        streak++;
        box.put('currentStreak', streak);

        // Lấy thông tin user mới nhất từ API
        final dio = Dio();
        final client = UserService(dio);
        final userResponse = await client.getMyInfo("Bearer $token");

        if (userResponse.code == 0) {
          final user = userResponse.result;
          final newPoints = user.points ?? 0;

          // Cập nhật điểm trong box
          box.put('totalPoints', newPoints);

          setState(() {
            _checkInStatus = "Đã điểm danh hôm nay";
            _currentStreak = streak;
            _totalPoints = newPoints;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Điểm danh thành công! +100 điểm"),
              backgroundColor: Colors.green,
            ),
          );

          // Kiểm tra và nhận thưởng nếu đạt điều kiện
          if (_currentStreak % 3 == 0) {
            await _checkAndClaimRewards();
          }
        }
      } else if (response.contains("đã điểm danh")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bạn đã điểm danh hôm nay!"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception("Lỗi không xác định: $response");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndClaimRewards() async {
    if (_isRewardLoading) return;

    setState(() {
      _isRewardLoading = true;
    });

    try {
      var box = await Hive.openBox('userBox');
      final token = box.get('token');
      if (token == null) return;

      final response = await _apiService.claimRewards("Bearer $token");

      if (response.contains("không đủ điều kiện")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Streak hiện tại không đủ điều kiện nhận thưởng"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Lấy điểm từ bảng user_info
        final dio = Dio();
        final client = UserService(dio);
        final userResponse = await client.getMyInfo("Bearer $token");

        if (userResponse.code == 0) {
          final user = userResponse.result;
          final newPoints = user.points ?? 0;

          // Cập nhật điểm
          box.put('totalPoints', newPoints);

          setState(() {
            _totalPoints = newPoints;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Nhận thưởng thành công! Điểm hiện tại: $newPoints"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Lỗi khi nhận thưởng: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi nhận thưởng: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRewardLoading = false;
      });
    }
  }

  Future<UserResponse> _loadUserPoints() async {
    try {
      var box = await Hive.openBox('userBox');
      final token = box.get('token');
      if (token == null) throw Exception("Token không tồn tại");

      final dio = Dio();
      final client = UserService(dio);
      return await client.getMyInfo("Bearer $token");
    } catch (e) {
      print("❌ Lỗi khi lấy điểm từ API: $e");
      rethrow;
    }
  }

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
              Text("Thành tựu",
                  style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text("Xem thêm",
                  style:
                      GoogleFonts.urbanist(color: Colors.green, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Phần điểm danh
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 26, 25, 25),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Điểm danh hằng ngày",
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _checkInStatus,
                          style: GoogleFonts.urbanist(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // tạo khoảng cách an toàn
                  ElevatedButton(
                    onPressed:
                        _checkInStatus == "Đã điểm danh hôm nay" || _isLoading
                            ? null
                            : _handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _checkInStatus == "Đã điểm danh hôm nay"
                                ? "Đã điểm danh"
                                : "Điểm danh",
                            style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FutureBuilder<UserResponse>(
                    future: _loadUserPoints(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Lỗi: ${snapshot.error}',
                          style: GoogleFonts.urbanist(color: Colors.red),
                        );
                      }
                      final points = snapshot.data?.result?.points ?? 0;
                      return _buildStatItem("Điểm", "$points", Colors.green);
                    },
                  ),
                ],
              ),

              // Hiển thị nút nhận thưởng nếu đủ điều kiện
              if (_currentStreak > 0 && _currentStreak % 3 == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: _isRewardLoading ? null : _checkAndClaimRewards,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isRewardLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.card_giftcard,
                                  color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                "Nhận thưởng",
                                style: GoogleFonts.urbanist(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: awards.map((award) {
              final bool isEligible = _currentStreak >= (award["days"] as int);
              return AwardCard(award, isEligible);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AwardCard extends StatelessWidget {
  final Map<String, dynamic> award;
  final bool isEligible;

  const AwardCard(this.award, this.isEligible, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 25, 25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isEligible ? award["color"] as Color : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            award["icon"] as IconData,
            color: isEligible ? award["color"] as Color : Colors.grey,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            award["title"]!,
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            award["subtitle"]!,
            style: GoogleFonts.urbanist(
              color: isEligible ? award["color"] as Color : Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEligible
                  ? award["color"] as Color
                  : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEligible)
                  const Icon(Icons.lock, size: 12, color: Colors.grey),
                if (!isEligible) const SizedBox(width: 3),
                Text(
                  "+${award["points"]} điểm",
                  style: GoogleFonts.urbanist(
                    color: isEligible ? Colors.white : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
