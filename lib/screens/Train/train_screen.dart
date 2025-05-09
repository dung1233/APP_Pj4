import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/Train/icons_user.dart';
import 'package:training_souls/screens/UI/Beginer/beginerdata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Thêm import Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:training_souls/screens/Train/beginer_screnn.dart';
import 'package:training_souls/screens/Train/wellcome.dart';
import 'package:training_souls/providers/workout_provider.dart'; // Import WorkoutProvider
import 'package:training_souls/providers/auth_provider.dart'; // Import AuthProvider

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  _TrainScreenState createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final GlobalKey _showcaseBeginnerKey = GlobalKey();
  final GlobalKey _showcaseMediumKey = GlobalKey();
  final GlobalKey _showcaseHardKey = GlobalKey();
  final GlobalKey _showcasetaskKey = GlobalKey();

  bool _isShowcaseActive = false;
  bool _hasSeenTutorial = false;
  bool _isDataReady = false;

  @override
  void initState() {
    super.initState();
    _initializeTutorial();
    printBasicWorkoutsInfo();
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

  // Hàm xử lý khi nhấn nút cập nhật
  // Trong _TrainScreenState
  void _refreshWorkouts() async {
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
      await workoutProvider.syncWorkouts(authProvider.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(workoutProvider.workouts.isNotEmpty
                ? 'Đã cập nhật danh sách bài tập!'
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
          automaticallyImplyLeading: false,
          title: Text(
            "Danh sách bài tập",
            style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
          ),
          actions: [
            // Nút cập nhật
            Consumer<WorkoutProvider>(
              builder: (context, provider, child) => IconButton(
                icon: Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : _refreshWorkouts,
                tooltip: 'Cập nhật bài tập',
              ),
            ),
          ],
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
      builder: (context) => SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              IconsUser(),
              Showcase(
                key: _showcasetaskKey,
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
                  _buildSection("Beginner Section", BeginnerDataWidget()),
                  // _buildSection("Medium Section", MediumDataWidget())
                ],
              ),
            ],
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
      _showcasetaskKey,
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
}
