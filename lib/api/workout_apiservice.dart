import 'package:dio/dio.dart';
import 'package:training_souls/models/work_history.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class WorkoutApiService {
  final Dio _dio;
  final String _baseUrl = 'http://54.251.220.228:8080/trainingSouls';

  String? _authToken;

  // Singleton pattern
  static final WorkoutApiService _instance = WorkoutApiService._internal();

  factory WorkoutApiService() {
    return _instance;
  }

  WorkoutApiService._internal() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Đọc token từ Hive và lưu vào biến _authToken
  Future<void> loadTokenFromStorage() async {
    var box = await Hive.openBox('userBox');
    String? token = box.get('token');
    if (token != null) {
      _authToken = token;
      if (kDebugMode) {
        print('✅ Token đã được load từ Hive: $_authToken');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ Không tìm thấy token trong Hive');
      }
    }
  }

  /// Lấy lịch sử tập luyện (có auto load token)
  Future<List<WorkoutHistory>> getWorkoutHistory() async {
    try {
      // Load token từ Hive nếu chưa có
      if (_authToken == null) {
        await loadTokenFromStorage();
      }

      if (_authToken == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await _dio.get(
        '/workout/history',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken', // 👈 thêm "Bearer "
          },
        ),
      );

      if (kDebugMode) {
        print('[DEBUG] 📊 Response from API: ${response.data}');
      }

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<WorkoutHistory> workouts =
            data.map((item) => WorkoutHistory.fromJson(item)).toList();

        if (kDebugMode) {
          print('[DEBUG] 📊 Đã lấy ${workouts.length} kết quả từ API');
        }

        return workouts;
      } else {
        throw Exception('Lỗi khi lấy dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ERROR] 🔴 getWorkoutHistory: $e');
      }
      return [];
    }
  }

  /// Lấy lịch sử tập luyện theo ngày
  Future<List<WorkoutHistory>> getWorkoutHistoryByDate(DateTime date) async {
    try {
      List<WorkoutHistory> allHistory = await getWorkoutHistory();

      return allHistory.where((workout) {
        try {
          DateTime workoutDate = DateTime.parse(workout.createdAt);
          return workoutDate.year == date.year &&
              workoutDate.month == date.month &&
              workoutDate.day == date.day;
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('[ERROR] 🔴 getWorkoutHistoryByDate: $e');
      }
      return [];
    }
  }

  /// Cho phép cập nhật token thủ công nếu muốn
  void updateToken(String token) {
    _authToken = token;
  }
}
