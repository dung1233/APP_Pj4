import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/screens/Train/icons_user.dart';
import 'package:training_souls/screens/UI/Beginer/beginerdata.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:training_souls/screens/Train/beginer_screnn.dart';
import 'package:training_souls/screens/Train/wellcome.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TrainScreenState createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final GlobalKey _showcaseBeginnerKey = GlobalKey();
  final GlobalKey _showcaseMediumKey = GlobalKey();
  final GlobalKey _showcaseHardKey = GlobalKey();
  final GlobalKey _showcasetaskKey = GlobalKey();

  bool _isShowcaseActive = false;
  bool _hasSeenTutorial = false;
  bool _isDataReady = false; // ✅ Thêm cờ kiểm soát trạng thái load data

  @override
  void initState() {
    super.initState();
    _initializeTutorial();
  }

  Future<void> _initializeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    if (mounted) {
      setState(() => _isDataReady = true); // ✅ Đánh dấu đã load xong data
    }

    debugPrint('🎯 Tutorial status loaded: $_hasSeenTutorial');
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        body: _isDataReady
            ? _buildMainContent(context)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    // Chỉ chạy showcase khi:
    // 1. Đã load xong data
    // 2. Chưa xem tutorial
    // 3. Chưa active showcase
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
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Showcase(
                    key: _showcaseBeginnerKey,
                    description: "Bài tập .",
                    child: BeginerScrenn(),
                  ),
                  _buildSection("Beginer Section", BeginnerDataWidget()),
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
    // ignore: unnecessary_null_comparison
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
