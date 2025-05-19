part of 'meal_suggestion.dart';

MealSuggestion _$MealSuggestionFromJson(Map<String, dynamic> json) =>
    MealSuggestion(
      code: json['code'] as int,
      message: json['message'] as String,
      result: json['result'] as String,
    );

Map<String, dynamic> _$MealSuggestionToJson(MealSuggestion instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'result': instance.result,
    };
