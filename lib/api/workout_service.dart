// lib/services/workout_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app/models/user_data.dart';
import 'package:app/models/work_out.dart';
import 'package:app/api/api_service.dart';

class WorkoutService {
  final ApiService apiService;
  WorkoutService(this.apiService);
  Future<List<Workout>> fetchWorkouts(UserData userData) async {
    try {
      // Gọi API để tạo danh sách bài tập
      final List<Workout> workouts = await apiService.generateWorkout(userData);
      if (kDebugMode) {
        print("📡 Phản hồi từ API: ${workouts.toString()}");
      }
      return workouts;
    } on DioException catch (e) {
      if (e.response != null) {
        print(
            "❌ Lỗi từ máy chủ: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("❌ Lỗi khác: ${e.message}");
      }
      rethrow; // Ném lại lỗi để xử lý ở nơi gọi
    } catch (e) {
      print("❌ Lỗi khi xử lý dữ liệu: $e");
      rethrow; // Ném lại lỗi để xử lý ở nơi gọi
    }
  }
}
