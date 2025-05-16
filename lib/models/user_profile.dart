import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final int id;
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;
  final double? bmi;
  final double? bodyFatPercentage;
  final double? muscleMassPercentage;
  final String? activityLevel;
  final String? fitnessGoal;
  final String? level;
  final List<String> medicalConditions;
  final int? strength;
  final int? deathPoints;
  final int? agility;
  final int? endurance;
  final int? health;

  UserProfile({
    required this.id,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.bmi,
    this.bodyFatPercentage,
    this.muscleMassPercentage,
    this.activityLevel,
    this.fitnessGoal,
    this.level,
    this.medicalConditions = const [],
    this.strength,
    this.deathPoints,
    this.agility,
    this.endurance,
    this.health,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      bmi: json['bmi'] as double?,
      bodyFatPercentage: json['bodyFatPercentage'] as double?,
      muscleMassPercentage: json['muscleMassPercentage'] as double?,
      activityLevel: json['activityLevel'] as String?,
      fitnessGoal: json['fitnessGoal'] as String?,
      level: json['level'] as String?,
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      strength: json['strength'] as int?,
      deathPoints: json['deathPoints'] as int?,
      agility: json['agility'] as int?,
      endurance: json['endurance'] as int?,
      health: json['health'] as int?,
    );
  }
}