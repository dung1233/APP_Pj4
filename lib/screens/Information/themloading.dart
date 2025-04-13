import 'package:training_souls/api/workout_service.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/api/dio_client.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/models/user_data.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/trainhome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ThemLoadingScreen extends StatefulWidget {
  const ThemLoadingScreen({super.key});

  @override
  State<ThemLoadingScreen> createState() => _ThemLoadingScreenState();
}

class _ThemLoadingScreenState extends State<ThemLoadingScreen> {
  bool isLoading = true; // ✅ Trạng thái loading

  @override
  void initState() {
    super.initState();
    _fetchAndSaveWorkouts();
  }

  Future<void> _fetchAndSaveWorkouts() async {
    setState(() => isLoading = true);

    final userDataMap = await LocalStorage.loadUserData();
    final userData = UserData.fromJson(userDataMap);

    if (kDebugMode) {
      print('📡 Dữ liệu đọc được: ${userData.toJson()}');
    }

    final apiService = ApiService(DioClient.dio);
    final workoutService = WorkoutService(apiService);
    final dbHelper = DatabaseHelper();

    try {
      await apiService.sendUserData(userData);
      if (kDebugMode) {
        print("✅ Đã gửi thông tin người dùng thành công!");
      }

      // ✅ Lấy danh sách bài tập từ API
      final List<Workout> workouts =
          await workoutService.fetchWorkouts(userData);

      // ✅ Lưu dữ liệu vào SQLite
      await dbHelper.clearWorkouts(); // Xóa dữ liệu cũ (nếu có)
      for (var workout in workouts) {
        await dbHelper.insertWorkout(workout); // Lưu từng bài tập vào SQLite
      }
      if (kDebugMode) {
        print('✅ Đã lưu ${workouts.length} bài tập vào SQLite!');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Trainhome()),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Lỗi khi gọi API: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo bài tập: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/img/Animation_1740914934240.json"),
                  const Text('Đang chuẩn bị bài tập...'),
                ],
              )
            : const Text('Đã tải xong!'),
      ),
    );
  }
}
