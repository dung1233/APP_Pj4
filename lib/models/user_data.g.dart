// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      gender: json['gender'] as String,
      age: (json['age'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      activity_level: json['activity_level'] as String,
      fitness_goal: json['fitness_goal'] as String,
      medical_conditions: json['medical_conditions'] as String,
      level: json['level'] as String,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'gender': instance.gender,
      'age': instance.age,
      'height': instance.height,
      'weight': instance.weight,
      'activity_level': instance.activity_level,
      'fitness_goal': instance.fitness_goal,
      'medical_conditions': instance.medical_conditions,
      'level': instance.level,
    };
