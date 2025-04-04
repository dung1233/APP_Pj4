// TODO Implement this library.
import 'package:json_annotation/json_annotation.dart';

part 'user_data.g.dart';

@JsonSerializable()
class UserData {
  final String gender;
  final int age;
  final int height;
  final int weight;
  // ignore: non_constant_identifier_names
  final String activity_level;
  // ignore: non_constant_identifier_names
  final String fitness_goal;
  // ignore: non_constant_identifier_names
  final String medical_conditions;
  final String level;

  UserData({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    // ignore: non_constant_identifier_names
    required this.activity_level,
    // ignore: non_constant_identifier_names
    required this.fitness_goal,
    // ignore: non_constant_identifier_names
    required this.medical_conditions,
    required this.level,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
