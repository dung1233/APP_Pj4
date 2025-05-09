import 'package:flutter/material.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Workout> _workouts = [];
  bool _isLoading = false;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;

  final ApiService _apiService;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  WorkoutProvider(this._apiService) {
    // Tải dữ liệu từ SQLite khi khởi tạo
    ensureWorkoutsLoaded();
  }

  // Đảm bảo dữ liệu được tải nếu danh sách rỗng
  Future<void> ensureWorkoutsLoaded() async {
    if (_workouts.isEmpty && !_isLoading) {
      await loadWorkoutsFromSQLite();
    }
  }

  // Làm mới dữ liệu sau khi database thay đổi
  Future<void> refreshAfterDatabaseChange() async {
    await loadWorkoutsFromSQLite();
  }

  Future<void> syncWorkouts(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Workout> fetchedWorkouts =
          await _apiService.getWorkouts("Bearer $token");
      print("DEBUG: Fetched ${fetchedWorkouts.length} workouts from API");

      await _dbHelper.clearWorkouts();
      await _dbHelper
          .insertMultipleWorkouts(fetchedWorkouts); // Sử dụng phương thức mới
      _workouts = fetchedWorkouts;
      print("✅ Đã đồng bộ ${_workouts.length} bài tập mới vào SQLite!");

      await refreshAfterDatabaseChange(); // Làm mới sau khi lưu
    } catch (e) {
      print("❌ Lỗi khi đồng bộ bài tập: $e");
      await refreshAfterDatabaseChange(); // Vẫn làm mới để đảm bảo dữ liệu
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAndSaveWorkouts(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Workout> fetchedWorkouts =
          await _apiService.getWorkouts("Bearer $token");

      await _dbHelper.clearWorkouts();
      await _dbHelper.saveWorkoutsAndNotify(
          fetchedWorkouts, this); // Sử dụng phương thức mới
      _workouts = fetchedWorkouts;

      print("✅ Đã lưu ${_workouts.length} bài tập vào SQLite!");
    } catch (e) {
      print("❌ Lỗi khi lấy bài tập: $e");
      await refreshAfterDatabaseChange(); // Làm mới nếu có lỗi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkoutsFromSQLite() async {
    _isLoading = true;
    notifyListeners();

    try {
      _workouts = await _dbHelper.getWorkouts();
      if (_workouts.isNotEmpty) {
        print("📌 Đã tải ${_workouts.length} bài tập từ SQLite!");
      } else {
        print("⚠️ Không có dữ liệu trong SQLite.");
      }
    } catch (e) {
      print("❌ Lỗi khi tải từ SQLite: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateWorkouts(List<Workout> newWorkouts) {
    _workouts = newWorkouts;
    notifyListeners();
  }
}
