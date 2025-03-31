import 'package:json_annotation/json_annotation.dart';

part 'work_out.g.dart'; // File được sinh tự động bởi json_serializable

@JsonSerializable() // Annotation để chỉ định lớp này có thể serialize/deserialize JSON
class Workout {
  final int? id;
  final int? day;
  final String? img;
  final String? icon;
  final String? exerciseName;
  final int? sets;
  final int? reps;
  final int? duration;
  final bool? restDay;
  final double? distance;
  String status;

  Workout({
    this.id,
    this.day,
    this.img,
    this.icon,
    this.exerciseName,
    this.sets,
    this.reps,
    this.duration,
    this.restDay,
    this.distance,
    this.status = "NOT_STARTED",
  });

  // Phương thức từ JSON sang đối tượng Workout
  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  // Phương thức từ đối tượng Workout sang JSON
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  // Phương thức từ Map sang Workout (dùng cho SQLite)
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      day: map['day'],
      img: map['img'],
      icon: map['icon'],
      exerciseName: map['exerciseName'],
      sets: map['sets'],
      reps: map['reps'],
      duration: map['duration'],
      restDay: map['restDay'] ==
          1, // SQLite không hỗ trợ bool, nên lưu dưới dạng int (0 hoặc 1)
      distance: map['distance'],
      status: map['status'] ?? "NOT_STARTED",
    );
  }

  // Phương thức từ Workout sang Map (dùng cho SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'img': img,
      'icon': icon,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'restDay': restDay == true ? 1 : 0, // Chuyển bool thành int
      'distance': distance,
      'status': status,
    };
  }
}
