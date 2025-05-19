import 'package:json_annotation/json_annotation.dart';

part 'meal_suggestion.g.dart';

@JsonSerializable()
class MealSuggestion {
  final int code;
  final String message;
  final String result;

  MealSuggestion({
    required this.code,
    required this.message,
    required this.result,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) =>
      _$MealSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$MealSuggestionToJson(this);
}
