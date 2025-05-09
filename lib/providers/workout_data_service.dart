import 'package:flutter/material.dart';
import 'package:training_souls/models/work_history.dart';

// Class để quản lý dữ liệu tập luyện và chia sẻ giữa các màn hình
class WorkoutDataService extends ChangeNotifier {
  DateTime? _selectedDate;
  List<WorkoutHistory> _selectedDateWorkouts = [];
  bool _loadingWorkoutDetails = false;

  // Map để cache dữ liệu ngày có workouts
  Map<DateTime, bool> _completedWorkoutDays = {};
  bool _loadingCalendarData = false;

  // Getters
  DateTime? get selectedDate => _selectedDate;
  List<WorkoutHistory> get selectedDateWorkouts => _selectedDateWorkouts;
  bool get loadingWorkoutDetails => _loadingWorkoutDetails;
  Map<DateTime, bool> get completedWorkoutDays => _completedWorkoutDays;
  bool get loadingCalendarData => _loadingCalendarData;

  // Method để cập nhật dữ liệu khi chọn ngày mới
  void updateSelectedDateWorkouts(
      DateTime date, List<WorkoutHistory> workouts) {
    _selectedDate = date;
    _selectedDateWorkouts = workouts;
    notifyListeners(); // Thông báo cho các widget đang lắng nghe
  }

  // Method để cập nhật trạng thái loading
  void setLoadingWorkoutDetails(bool isLoading) {
    _loadingWorkoutDetails = isLoading;
    notifyListeners();
  }

  // Cập nhật dữ liệu ngày có workouts
  void updateCompletedWorkoutDays(Map<DateTime, bool> data) {
    _completedWorkoutDays = data;
    notifyListeners();
  }

  // Cập nhật trạng thái loading lịch
  void setLoadingCalendarData(bool isLoading) {
    _loadingCalendarData = isLoading;
    notifyListeners();
  }
}
