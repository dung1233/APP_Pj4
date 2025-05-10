import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;
  final double? bmi;
  final double? bodyFatPercentage;
  final double? muscleMassPercentage;
  final String? activityLevel; // Có thể là null
  final String? fitnessGoal; // Có thể là null
  final String level;
  final List<String> medicalConditions; // Nếu là mảng
  final int strength;
  final int deathPoints;
  final int agility;
  final int endurance;
  final int health;

  UserProfile({
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.bmi,
    this.bodyFatPercentage,
    this.muscleMassPercentage,
    this.activityLevel,
    this.fitnessGoal,
    required this.level,
    required this.medicalConditions,
    required this.strength,
    required this.deathPoints,
    required this.agility,
    required this.endurance,
    required this.health,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      bmi: json['bmi'] as double?,
      bodyFatPercentage: json['bodyFatPercentage'] as double?,
      muscleMassPercentage: json['muscleMassPercentage'] as double?,
      activityLevel: json['activityLevel'] as String?, // Có thể là null
      fitnessGoal: json['fitnessGoal'] as String?, // Có thể là null
      level: json['level'] as String,
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      strength: json['strength'] as int,
      deathPoints: json['deathPoints'] as int,
      agility: json['agility'] as int,
      endurance: json['endurance'] as int,
      health: json['health'] as int,
    );
  }
}
