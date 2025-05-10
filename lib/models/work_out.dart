import 'package:json_annotation/json_annotation.dart';

part 'work_out.g.dart'; // File được sinh tự động bởi json_serializable

@JsonSerializable()
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
  String? completionDate;
  String? workoutDate; // 👈 Thêm trường workoutDate

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
    this.completionDate,
    this.workoutDate, // 👈 Thêm vào constructor
  });

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

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
      restDay: map['restDay'] == 1,
      distance: map['distance'],
      status: map['status'] ?? "NOT_STARTED",
      completionDate: map['completionDate'],
      workoutDate: map['workoutDate'], // 👈 Thêm vào đây
    );
  }

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
      'restDay': restDay == true ? 1 : 0,
      'distance': distance,
      'status': status,
      'completionDate': completionDate,
      'workoutDate': workoutDate, // 👈 Thêm vào đây
    };
  }
}
