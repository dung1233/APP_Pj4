import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'work_out.g.dart';

@HiveType(typeId: 0) // Định danh duy nhất cho Hive
@JsonSerializable() // Dùng cho JSON
class Workout extends HiveObject {
  @HiveField(0)
  final int? day; // ✅ Cho phép null

  @HiveField(1)
  final String? img; // ✅ Cho phép null

  @HiveField(2)
  final String? icon; // ✅ Cho phép null

  @HiveField(3)
  final String? exerciseName; // ✅ Cho phép null

  @HiveField(4)
  final int? sets; // ✅ Cho phép null

  @HiveField(5)
  final int? reps; // ✅ Cho phép null

  @HiveField(6)
  final int? duration; // ✅ Cho phép null

  @HiveField(7)
  final bool? restDay; // ✅ Cho phép null

  @HiveField(8)
  final double? distance; // ✅ Cho phép null

  Workout({
    this.day,
    this.img,
    this.icon,
    this.exerciseName,
    this.sets,
    this.reps,
    this.duration,
    this.restDay,
    this.distance,
  });

  /// ✅ Chuyển từ JSON → Object
  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  /// ✅ Chuyển từ Object → JSON
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}
