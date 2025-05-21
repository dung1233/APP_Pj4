import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training_souls/models/workout_model.dart';
import 'package:training_souls/models/workout_result_model.dart';

class WorkoutService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://54.251.220.228:8080/trainingSouls';

  Future<void> updateWorkout(String userId, List<Workout> workouts) async {
    try {
      if (kDebugMode) {
        print("Updating workouts for user: $userId");
        print("Request data: ${workouts.map((w) => w.toJson()).toList()}");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.put(
        '$_baseUrl/workout/update/$userId',
        data: workouts.map((w) => w.toJson()).toList(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (kDebugMode) {
        print("API Response Status: ${response.statusCode}");
        print("API Response Data: ${response.data}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating workouts: $e");
        if (e is DioException) {
          print("Request data: ${e.requestOptions.data}");
          print("Response data: ${e.response?.data}");
        }
      }
      throw Exception('Failed to update workouts: $e');
    }
  }

  Future<List<WorkoutResult>> getWorkoutHistory(String studentId) async {
    try {
      if (kDebugMode) {
        print(
            "WorkoutService: Fetching workout history for student $studentId");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.get(
        '$_baseUrl/coach/getWorkoutResults/$studentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (kDebugMode) {
        print("WorkoutService: Response status code: ${response.statusCode}");
        print("WorkoutService: Response data: ${response.data}");
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WorkoutResult.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load workout history');
      }
    } catch (e) {
      if (kDebugMode) {
        print("WorkoutService: Error fetching workout history: $e");
      }
      rethrow;
    }
  }
}
