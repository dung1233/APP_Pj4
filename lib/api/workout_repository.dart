import 'package:app/models/work_out.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:app/api/api_service.dart';

import 'package:app/models/user_data.dart';

class WorkoutRepository {
  final ApiService apiService = ApiService(Dio());

  Future<void> fetchAndSaveWorkouts(UserData userData) async {
    try {
      List<Workout> workouts = await apiService.generateWorkout(userData);
      var box = Hive.box<Workout>('workoutBox');

      for (var workout in workouts) {
        box.add(workout);
      }
      print("✅ Đã lưu bài tập vào Hive");
    } catch (e) {
      print("❌ Lỗi khi gọi API hoặc lưu dữ liệu: $e");
    }
  }
}
