import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/UI/Beginer/situp.dart';
import 'package:training_souls/screens/Train/train_screen.dart';
import 'package:provider/provider.dart';
import 'package:training_souls/providers/workout_provider.dart';
import 'package:training_souls/screens/trainhome.dart';

class Restb extends StatefulWidget {
  final int day;

  const Restb({Key? key, required this.day}) : super(key: key);

  @override
  State<Restb> createState() => _RestbState();
}

class _RestbState extends State<Restb> {
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int completedWorkouts = 0;
  bool _isSyncing = false;

  Color primaryColor = Color(0xFFFF6B00);
  Color secondaryColor = Color(0xFF333333);
  Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await _dbHelper.getAllWorkoutResults();

      // Đếm số bài tập đã hoàn thành trong ngày
      final todayCompleted =
          results.where((result) => result['day_number'] == widget.day).length;

      if (mounted) {
        setState(() {
          completedWorkouts = todayCompleted;
        });
      }

      debugPrint("Số bài tập đã hoàn thành: $completedWorkouts");
    } catch (e) {
      debugPrint("Error loading workout data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon chúc mừng
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  size: 60,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 40),

              // Tiêu đề chúc mừng
              Text(
                'Chúc mừng!',
                style: GoogleFonts.urbanist(
                  color: secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 20),

              // Thông báo hoàn thành
              Text(
                'Bạn đã hoàn thành\n$completedWorkouts bài tập hôm nay!',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  color: secondaryColor,
                  fontSize: 20,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Streak point display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+1 Streak',
                      style: GoogleFonts.urbanist(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Thông tin ngày
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Ngày ${widget.day}',
                  style: GoogleFonts.urbanist(
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Lời động viên
              Text(
                'Hãy giữ vững phong độ này nhé!\nTiếp tục luyện tập để đạt mục tiêu.',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  color: Colors.grey[600],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),

              // Nút hoàn thành
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: Size(280, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                onPressed: _isSyncing
                    ? null
                    : () async {
                        setState(() => _isSyncing = true);
                        try {
                          // Gọi hàm sync và refresh
                          await _dbHelper.checkAndSyncWorkouts(widget.day);
                          if (mounted) {
                            await Provider.of<WorkoutProvider>(context,
                                    listen: false)
                                .refreshAfterDatabaseChange();
                          }

                          // Quay về màn hình TrainScreen hoặc màn hình chính
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Trainhome()),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đã xảy ra lỗi khi đồng bộ dữ liệu. Vui lòng thử lại sau.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isSyncing = false);
                          }
                        }
                      },
                child: _isSyncing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Hoàn Thành',
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Nút tiếp tục tập thêm (tùy chọn)
              // TextButton(
              //   onPressed: () {
              //     // Quay lại trang Rest để tiếp tục tập
              //     Navigator.pop(context);
              //   },
              //   child: Text(
              //     'Tiếp tục tập thêm',
              //     style: GoogleFonts.urbanist(
              //       color: primaryColor,
              //       fontWeight: FontWeight.w600,
              //       fontSize: 16,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
