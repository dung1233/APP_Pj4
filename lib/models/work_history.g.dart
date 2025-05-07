// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutHistory _$WorkoutHistoryFromJson(Map<String, dynamic> json) =>
    WorkoutHistory(
      exerciseName: json['exerciseName'] as String,
      setsCompleted: (json['setsCompleted'] as num).toInt(),
      repsCompleted: (json['repsCompleted'] as num).toInt(),
      distanceCompleted: (json['distanceCompleted'] as num).toDouble(),
      durationCompleted: (json['durationCompleted'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$WorkoutHistoryToJson(WorkoutHistory instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'setsCompleted': instance.setsCompleted,
      'repsCompleted': instance.repsCompleted,
      'distanceCompleted': instance.distanceCompleted,
      'durationCompleted': instance.durationCompleted,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };
