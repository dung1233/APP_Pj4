import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/Train/icons_user.dart';
import 'package:training_souls/screens/UI/Beginer/beginerdata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:training_souls/screens/Train/beginer_screnn.dart';
import 'package:training_souls/screens/Train/wellcome.dart';
import 'package:training_souls/providers/workout_provider.dart';
import 'package:training_souls/providers/auth_provider.dart';

import '../../data/local_storage.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  _TrainScreenState createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final GlobalKey _showcaseBeginnerKey = GlobalKey();
  final GlobalKey _showcaseMediumKey = GlobalKey();
  final GlobalKey _showcaseHardKey = GlobalKey();
  final GlobalKey _showcaseTaskKey = GlobalKey();

  bool _isShowcaseActive = false;
  bool _hasSeenTutorial = false;
  bool _isDataReady = false;
  final dbHelper = DatabaseHelper();
  Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _userInfo = {};
  double _powerLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeTutorial();
    printBasicWorkoutsInfo();
    _loadUserProfile(dbHelper);
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

  Future<void> printBasicWorkoutsInfo() async {
    try {
      final dbHelper = DatabaseHelper();
      final workouts = await dbHelper.getWorkouts();

      if (kDebugMode) {
        print("\n[DEBUG] 📊 DANH SÁCH ${workouts.length} BÀI TẬP:");
        print("----------------------------------------");

        for (int i = 0; i < workouts.length; i++) {
          final workout = workouts[i];
          print(
              "${i + 1}. ${workout.exerciseName} | Day ${workout.day} | ${workout.status}");
        }

        print("----------------------------------------");

        int completed = workouts.where((w) => w.status == 'COMPLETED').length;
        int notStarted =
            workouts.where((w) => w.status == 'NOT_STARTED').length;
        int inProgress =
            workouts.where((w) => w.status == 'IN_PROGRESS').length;

        print(
            "Đã hoàn thành: $completed | Chưa bắt đầu: $notStarted | Đang thực hiện: $inProgress");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[DEBUG] ❌ Lỗi khi in danh sách bài tập: $e");
      }
    }
  }

  Future<void> _initializeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    if (mounted) {
      setState(() => _isDataReady = true);
    }

    debugPrint('🎯 Tutorial status loaded: $_hasSeenTutorial');
  }

  // Hàm xử lý khi làm mới dữ liệu
  Future<void> _refreshWorkouts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);

    // In token để debug
    if (kDebugMode) {
      print("DEBUG: Token in _refreshWorkouts: ${authProvider.token}");
    }

    // Kiểm tra token
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: Vui lòng đăng nhập lại!')),
        );
      }
      return;
    }

    try {
      // Refresh cả workouts và user profile
      await Future.wait([
        workoutProvider.syncWorkouts(authProvider.token!),
        _loadUserProfile(dbHelper), // Thêm refresh user profile
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(workoutProvider.workouts.isNotEmpty
                ? 'Đã cập nhật dữ liệu!'
                : 'Không có dữ liệu mới.'),
          ),
        );
        // Làm mới giao diện
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật dữ liệu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 5,
          automaticallyImplyLeading: false,
          // title: Text(
          //   "Danh sách bài tập",
          //   style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
          // ),
          // actions: [
          //   // Vẫn giữ lại nút refresh ở AppBar nếu cần
          //   Consumer<WorkoutProvider>(
          //     builder: (context, provider, child) => IconButton(
          //       icon: Icon(Icons.refresh),
          //       onPressed: provider.isLoading ? null : _refreshWorkouts,
          //       tooltip: 'Cập nhật bài tập',
          //     ),
          //   ),
          // ],
        ),
        body: _isDataReady
            ? _buildMainContent(context)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (!_isShowcaseActive && !_hasSeenTutorial) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _startShowCase(context));
    }

    return Builder(
      builder: (context) => RefreshIndicator(
        // Thêm RefreshIndicator ở đây
        onRefresh: () async {
          // Gọi hàm _refreshWorkouts khi người dùng kéo xuống để refresh
          await _refreshWorkouts();
        },
        child: SingleChildScrollView(
          // Cần bọc SingleChildScrollView vào một widget có kích thước cố định
          // để RefreshIndicator hoạt động đúng
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  IconsUser(),
                  Showcase(
                    key: _showcaseTaskKey,
                    description: "Task.",
                    child: Wellcome(),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Showcase(
                        key: _showcaseBeginnerKey,
                        description: "Bài tập.",
                        child: BeginerScrenn(),
                      ),
                      _buildSection(
                          "Chế Độ ${_capitalizeWords(_userProfile['level']?.toString() ?? "??")}",
                          BeginnerDataWidget()),
                      // _buildSection("Medium Section", MediumDataWidget())
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    shadowColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(color: Colors.transparent),
    ),
  );

  void _startShowCase(BuildContext context) {
    final showcase = ShowCaseWidget.of(context);
    if (showcase == null || !mounted) return;

    debugPrint('🚀 Starting Showcase...');
    showcase.startShowCase([
      _showcaseTaskKey,
      _showcaseBeginnerKey,
      _showcaseMediumKey,
      _showcaseHardKey,
    ]);

    _markTutorialAsSeen();
    setState(() => _isShowcaseActive = true);
  }

  Future<void> _markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', true);
    if (mounted) setState(() => _hasSeenTutorial = true);
    debugPrint('✅ Tutorial marked as seen');
  }

  // Thêm hàm helper để viết hoa chữ cái đầu của mỗi từ
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;

    // Xử lý các trường hợp đặc biệt
    final Map<String, String> specialCases = {
      'cao cấp': 'Cao Cấp',
      'trung cấp': 'Trung Cấp',
      'người mới': 'Người Mới',
      'beginner': 'Người Mới',
      'intermediate': 'Trung Cấp',
      'advanced': 'Cao Cấp'
    };

    // Kiểm tra nếu là trường hợp đặc biệt
    final lowerText = text.toLowerCase();
    if (specialCases.containsKey(lowerText)) {
      return specialCases[lowerText]!;
    }

    // Nếu không phải trường hợp đặc biệt, viết hoa chữ cái đầu của mỗi từ
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
