// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      id: (json['id'] as num?)?.toInt(),
      day: (json['day'] as num?)?.toInt(),
      img: json['img'] as String?,
      icon: json['icon'] as String?,
      exerciseName: json['exerciseName'] as String?,
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      restDay: json['restDay'] as bool?,
      distance: (json['distance'] as num?)?.toDouble(),
      status: json['status'] as String? ?? "NOT_STARTED",
      completionDate: json['completionDate'] as String?,
      workoutDate: json['workoutDate'] as String?,
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'img': instance.img,
      'icon': instance.icon,
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
      'reps': instance.reps,
      'duration': instance.duration,
      'restDay': instance.restDay,
      'distance': instance.distance,
      'status': instance.status,
      'completionDate': instance.completionDate,
      'workoutDate': instance.workoutDate,
    };
