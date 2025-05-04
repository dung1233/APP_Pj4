import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/providers/workout_data_service.dart';
// Import service

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({Key? key}) : super(key: key);

  @override
  _OnlineScreenState createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {
  late DateRangePickerController _datePickerController;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getheightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  @override
  void initState() {
    super.initState();
    _datePickerController = DateRangePickerController();
    _datePickerController.displayDate = DateTime.now();
  }

  // Hiển thị chi tiết workout cho ngày đã chọn
  Widget _buildWorkoutDetails(
      BuildContext context, WorkoutDataService service) {
    // Nếu đang loading dữ liệu
    if (service.loadingWorkoutDetails) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Nếu chưa chọn ngày
    if (service.selectedDate == null) {
      return const Center(
        child: Text(
          'Vui lòng chọn một ngày trên lịch để xem chi tiết tập luyện',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Nếu không có dữ liệu tập luyện cho ngày đã chọn
    if (service.selectedDateWorkouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fitness_center_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có hoạt động tập luyện nào vào ngày ${DateFormat('dd/MM/yyyy').format(service.selectedDate!)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (kDebugMode) {
                  print(
                      'Thêm hoạt động cho ngày ${DateFormat('dd/MM/yyyy').format(service.selectedDate!)}');
                }
                // TODO: Thêm code để thêm hoạt động mới
              },
              label: const Text('Thêm hoạt động'),
            ),
          ],
        ),
      );
    }

    // Hiển thị danh sách các hoạt động tập luyện cho ngày đã chọn
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Hoạt động ngày ${DateFormat('dd/MM/yyyy').format(service.selectedDate!)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: service.selectedDateWorkouts.length,
            itemBuilder: (context, index) {
              final workout = service.selectedDateWorkouts[index];
              return _buildWorkoutItem(workout);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (kDebugMode) {
                print(
                    'Thêm hoạt động cho ngày ${DateFormat('dd/MM/yyyy').format(service.selectedDate!)}');
              }
              // TODO: Thêm code để thêm hoạt động mới
            },
            label: const Text('Thêm hoạt động'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị một hoạt động tập luyện - Được cập nhật để phù hợp với dữ liệu thực tế
  Widget _buildWorkoutItem(Map<String, dynamic> workout) {
    // Lấy thông tin từ workout map theo cấu trúc thực tế từ database
    final int id = workout['id'] ?? 0;
    final int dayNumber = workout['day_number'] ?? 0;
    final String exerciseName = workout['exercise_name'] ?? 'Không có tên';
    final int setsCompleted = workout['sets_completed'] ?? 0;
    final int repsCompleted = workout['reps_completed'] ?? 0;
    final double distanceCompleted =
        workout['distance_completed']?.toDouble() ?? 0.0;
    final int durationCompleted = workout['duration_completed'] ?? 0;
    final String completedDate = workout['completed_date'] ?? '';

    // Xử lý định dạng ngày giờ nếu cần
    DateTime? parsedDate;
    try {
      if (completedDate.isNotEmpty) {
        parsedDate = DateTime.parse(completedDate);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi parse ngày: $e');
      }
    }

    // Tạo widget hiển thị chi tiết
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exerciseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildExerciseTypeIcon(exerciseName),
              ],
            ),
            const SizedBox(height: 8),
            // Hiển thị thông tin sets và reps
            Row(
              children: [
                const Icon(Icons.repeat, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$setsCompleted set × $repsCompleted lần',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            // Hiển thị thông tin khoảng cách và thời gian
            Row(
              children: [
                if (distanceCompleted > 0) ...[
                  const Icon(Icons.straighten, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${distanceCompleted.toStringAsFixed(1)} km',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                ],
                if (durationCompleted > 0) ...[
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$durationCompleted phút',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ],
            ),
            if (parsedDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Thời gian: ${DateFormat('HH:mm, dd/MM/yyyy').format(parsedDate)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Sửa'),
                  onPressed: () {
                    // TODO: Thêm code để sửa workout
                    if (kDebugMode) {
                      print('Sửa bài tập ID: $id');
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    // TODO: Thêm code để xóa workout
                    if (kDebugMode) {
                      print('Xóa bài tập ID: $id');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị icon cho loại tập luyện dựa trên tên bài tập
  Widget _buildExerciseTypeIcon(String exerciseName) {
    IconData iconData;
    Color iconColor;

    final exerciseNameLower = exerciseName.toLowerCase();

    if (exerciseNameLower.contains('chạy bộ') ||
        exerciseNameLower.contains('run') ||
        exerciseNameLower.contains('cardio')) {
      iconData = Icons.directions_run;
      iconColor = Colors.red;
    } else if (exerciseNameLower.contains('gập bụng') ||
        exerciseNameLower.contains('cycle') ||
        exerciseNameLower.contains('bike')) {
      iconData = Icons.directions_bike;
      iconColor = Colors.green;
    } else if (exerciseNameLower.contains('hít đất') ||
        exerciseNameLower.contains('push up') ||
        exerciseNameLower.contains('pushup')) {
      iconData = Icons.fitness_center;
      iconColor = Colors.blue;
    } else if (exerciseNameLower.contains('squat') ||
        exerciseNameLower.contains('stretch')) {
      iconData = Icons.self_improvement;
      iconColor = Colors.purple;
    } else if (exerciseNameLower.contains('bơi') ||
        exerciseNameLower.contains('swim')) {
      iconData = Icons.pool;
      iconColor = Colors.cyan;
    } else {
      iconData = Icons.sports;
      iconColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        width: getWidthPercentage(context, 1),
        height: getheightPercentage(context, 0.7),
        child: Consumer<WorkoutDataService>(
          builder: (context, workoutDataService, child) {
            // In ra dữ liệu để kiểm tra (xóa sau khi đã hoạt động đúng)
            if (kDebugMode && workoutDataService.selectedDate != null) {
              print('Selected date: ${workoutDataService.selectedDate}');
              print(
                  'Workouts count: ${workoutDataService.selectedDateWorkouts.length}');
              for (var workout in workoutDataService.selectedDateWorkouts) {
                print('Workout data: $workout');
              }
            }

            // Nếu đã chọn ngày, hiển thị chi tiết workout
            if (workoutDataService.selectedDate != null) {
              return _buildWorkoutDetails(context, workoutDataService);
            }

            // Nếu chưa chọn ngày, hiển thị màn hình mặc định
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 8),
                  child: Text(
                    _datePickerController.displayDate != null
                        ? "${_datePickerController.displayDate!.month.toString().padLeft(2, '0')}-${_datePickerController.displayDate!.year}"
                        : "00-0000",
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text('Hoạt Động'),
                ),
                const Center(
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.yellow,
                    size: 50,
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 300,
                      child: Text(
                        'Hồ sơ huấn luyện ở đây. Ngoài ra bạn có thể ghi lại các hoạt động của riêng bạn!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (kDebugMode) {
                        print('Đã vào hoạt động');
                      }
                    },
                    label: const Text(
                      'Thêm Hoạt Động',
                      style: TextStyle(color: Colors.black),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }
}
