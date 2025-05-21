import 'package:flutter/foundation.dart';

class StudentProfile {
  final String gender;
  final int age;
  final double height;
  final double weight;
  final String activityLevel;
  final String fitnessGoal;
  final String level;
  final List<String> medicalConditions;
  final int strength;
  final int endurance;
  final int health;
  final int agility;
  final int deathPoints;

  StudentProfile({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.fitnessGoal,
    required this.level,
    required this.medicalConditions,
    required this.strength,
    required this.endurance,
    required this.health,
    required this.agility,
    required this.deathPoints,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      height: (json['height'] ?? 0.0).toDouble(),
      weight: (json['weight'] ?? 0.0).toDouble(),
      activityLevel: json['activityLevel'] ?? '',
      fitnessGoal: json['fitnessGoal'] ?? '',
      level: json['level'] ?? '',
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      strength: json['strength'] ?? 0,
      endurance: json['endurance'] ?? 0,
      health: json['health'] ?? 0,
      agility: json['agility'] ?? 0,
      deathPoints: json['deathPoints'] ?? 0,
    );
  }
}
