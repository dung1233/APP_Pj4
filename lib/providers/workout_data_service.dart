import 'package:flutter/material.dart';

// Class để quản lý dữ liệu tập luyện và chia sẻ giữa các màn hình
class WorkoutDataService extends ChangeNotifier {
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _selectedDateWorkouts = [];
  bool _loadingWorkoutDetails = false;

  // Getters
  DateTime? get selectedDate => _selectedDate;
  List<Map<String, dynamic>> get selectedDateWorkouts => _selectedDateWorkouts;
  bool get loadingWorkoutDetails => _loadingWorkoutDetails;

  // Method để cập nhật dữ liệu khi chọn ngày mới
  void updateSelectedDateWorkouts(
      DateTime date, List<Map<String, dynamic>> workouts) {
    _selectedDate = date;
    _selectedDateWorkouts = workouts;
    notifyListeners(); // Thông báo cho các widget đang lắng nghe
  }

  // Method để cập nhật trạng thái loading
  void setLoadingWorkoutDetails(bool isLoading) {
    _loadingWorkoutDetails = isLoading;
    notifyListeners();
  }
}
