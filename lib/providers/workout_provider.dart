import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/api/api_service.dart';

import 'package:training_souls/models/work_out.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Workout> _workouts = [];
  bool _isLoading = false;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;

  final ApiService _apiService;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  WorkoutProvider(this._apiService);

  Future<void> fetchAndSaveWorkouts(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Workout> fetchedWorkouts =
          await _apiService.getWorkouts("Bearer $token");

      // ✅ Lưu dữ liệu vào SQLite
      await _dbHelper.clearWorkouts();
      for (var workout in fetchedWorkouts) {
        await _dbHelper.insertWorkout(workout);
      }
      _workouts = fetchedWorkouts;

      print("✅ Đã lưu ${_workouts.length} bài tập vào SQLite!");
    } catch (e) {
      print("❌ Lỗi khi lấy bài tập: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWorkoutsFromSQLite() async {
    _isLoading = true;
    notifyListeners();

    _workouts = await _dbHelper.getWorkouts();
    if (_workouts.isNotEmpty) {
      print("📌 Đã tải ${_workouts.length} bài tập từ SQLite!");
    } else {
      print("⚠️ Không có dữ liệu trong SQLite.");
    }

    _isLoading = false;
    notifyListeners();
  }
}
