// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: (json['id'] as num).toInt(),
      gender: json['gender'] as String?,
      age: (json['age'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      muscleMassPercentage: (json['muscleMassPercentage'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      fitnessGoal: json['fitnessGoal'] as String?,
      level: json['level'] as String?,
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          const [],
      strength: (json['strength'] as num?)?.toInt(),
      deathPoints: (json['deathPoints'] as num?)?.toInt(),
      agility: (json['agility'] as num?)?.toInt(),
      endurance: (json['endurance'] as num?)?.toInt(),
      health: (json['health'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
          'id': instance.id,
          'gender': instance.gender,
          'age': instance.age,
          'height': instance.height,
          'weight': instance.weight,
          'bmi': instance.bmi,
          'bodyFatPercentage': instance.bodyFatPercentage,
          'muscleMassPercentage': instance.muscleMassPercentage,
          'activityLevel': instance.activityLevel,
          'fitnessGoal': instance.fitnessGoal,
          'level': instance.level,
          'medicalConditions': instance.medicalConditions,
          'strength': instance.strength,
          'deathPoints': instance.deathPoints,
          'agility': instance.agility,
          'endurance': instance.endurance,
          'health': instance.health,
    };