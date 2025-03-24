import 'package:app/data/DatabaseHelper.dart';
import 'package:app/models/work_out.dart';
import 'package:dio/dio.dart';

import 'package:app/api/api_service.dart';

import 'package:app/models/user_data.dart';

class WorkoutRepository {
  final ApiService apiService = ApiService(Dio());
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> fetchAndSaveWorkouts(UserData userData) async {
    try {
      List<Workout> workouts = await apiService.generateWorkout(userData);

      // Lưu dữ liệu vào SQLite
      await dbHelper.clearWorkouts(); // Xóa dữ liệu cũ (nếu có)
      for (var workout in workouts) {
        await dbHelper.insertWorkout(workout); // Lưu từng bài tập vào SQLite
      }
      print("✅ Đã lưu bài tập vào SQLite");
    } catch (e) {
      print("❌ Lỗi khi gọi API hoặc lưu dữ liệu: $e");
    }
  }
}
