import 'package:json_annotation/json_annotation.dart';

part 'work_history.g.dart'; // File được sinh tự động bởi json_serializable

@JsonSerializable()
// Model riêng biệt cho dữ liệu lịch sử workout
class WorkoutHistory {
  final String exerciseName;
  final int setsCompleted;
  final int repsCompleted;
  final double distanceCompleted;
  final int durationCompleted;
  final String status;
  final String createdAt;

  WorkoutHistory({
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.distanceCompleted,
    required this.durationCompleted,
    required this.status,
    required this.createdAt,
  });

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutHistory(
      exerciseName: json['exerciseName'] ?? 'Chưa đặt tên',
      setsCompleted: json['setsCompleted'] != null
          ? (json['setsCompleted'] as num).toInt()
          : 0,
      repsCompleted: json['repsCompleted'] != null
          ? (json['repsCompleted'] as num).toInt()
          : 0,
      distanceCompleted: json['distanceCompleted'] != null
          ? (json['distanceCompleted'] as num).toDouble()
          : 0.0,
      durationCompleted: json['durationCompleted'] != null
          ? (json['durationCompleted'] as num).toInt()
          : 0,
      status: json['status'] ?? 'INCOMPLETE',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'setsCompleted': setsCompleted,
      'repsCompleted': repsCompleted,
      'distanceCompleted': distanceCompleted,
      'durationCompleted': durationCompleted,
      'status': status,
      'createdAt': createdAt,
    };
  }

  // Phương thức tiện ích để hiển thị ngày tháng dễ đọc
  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return 'Hôm nay';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Hôm nay';
    }
  }

  // Phương thức tiện ích để lấy văn bản hiển thị cho giá trị
  String getDisplayValue() {
    final bool isRun = exerciseName.toLowerCase().contains('run') ||
        exerciseName.toLowerCase().contains('chạy');

    if (isRun) {
      final distanceStr =
          distanceCompleted.toStringAsFixed(1).replaceAll('.', ',');
      final durationStr = durationCompleted.toString();
      return "$distanceStr Km - $durationStr p";
    } else {
      return "$setsCompleted sets - $repsCompleted reps";
    }
  }
}
