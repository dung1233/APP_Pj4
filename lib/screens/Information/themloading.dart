import 'package:training_souls/api/workout_service.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/api/dio_client.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/trainhome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dio/dio.dart';

class ThemLoadingScreen extends StatefulWidget {
  const ThemLoadingScreen({super.key});

  @override
  State<ThemLoadingScreen> createState() => _ThemLoadingScreenState();
}

class _ThemLoadingScreenState extends State<ThemLoadingScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSaveWorkouts();
  }

  Future<void> _fetchAndSaveWorkouts() async {
    setState(() => isLoading = true);

    try {
      // Lấy dữ liệu từ local storage
      final userDataMap = await LocalStorage.loadUserData();

      // Chuẩn bị dữ liệu để gửi lên API
      final Map<String, dynamic> requestData = {
        "gender": userDataMap['gender'],
        "age": userDataMap['age'],
        "height": userDataMap['height'],
        "weight": userDataMap['weight'],
        "activityLevel": userDataMap['activity_level'],
        "fitnessGoal": userDataMap['fitness_goal'],
        "level": userDataMap['level'],
        "medical_conditions": userDataMap['medical_conditions']
      };

      if (kDebugMode) {
        print('📡 Dữ liệu gửi lên API: $requestData');
      }

      // Lấy token
      final token = await LocalStorage.getValidToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      // Tạo Dio instance và cấu hình
      final dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Gọi API save profile
      final response = await dio.post(
        'http://54.251.220.228:8080/trainingSouls/users/save-profile',
        data: requestData,
      );

      if (kDebugMode) {
        print("✅ API Response: ${response.data}");
      }

      // Gọi API để lấy danh sách bài tập
      final workoutResponse = await dio.post(
        'http://54.251.220.228:8080/trainingSouls/workout/generate',
        data: requestData,
      );

      if (kDebugMode) {
        print("✅ Workout Response: ${workoutResponse.data}");
      }

      final dbHelper = DatabaseHelper();

      // Chuyển đổi response thành danh sách Workout
      final List<Workout> workouts = (workoutResponse.data as List)
          .map((item) => Workout.fromJson(item))
          .toList();

      // Lưu vào SQLite
      await dbHelper.clearWorkouts();
      for (var workout in workouts) {
        await dbHelper.insertWorkout(workout);
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
        print('❌ Lỗi: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
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
