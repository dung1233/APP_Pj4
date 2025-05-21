import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training_souls/models/workout_model.dart';
import 'package:training_souls/models/workout_result_model.dart';

class WorkoutService {
  final String baseUrl = 'http://54.251.220.228:8080/trainingSouls';

  Future<void> updateWorkout(String userId, List<Workout> workouts) async {
    try {
      print('Updating workouts for user: $userId');
      print('Number of workouts to update: ${workouts.length}');

      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Group workouts by day
      final Map<int, List<Workout>> workoutsByDay = {};
      for (var workout in workouts) {
        workoutsByDay.putIfAbsent(workout.day, () => []).add(workout);
      }

      print('Workouts grouped by day:');
      workoutsByDay.forEach((day, dayWorkouts) {
        print('Day $day: ${dayWorkouts.length} workouts');
        for (var workout in dayWorkouts) {
          print('- ${workout.exerciseName}');
        }
      });

      // Update each day's workouts
      for (var entry in workoutsByDay.entries) {
        final day = entry.key;
        final dayWorkouts = entry.value;

        final url = Uri.parse('$baseUrl/workout/update/$userId');
        print('Sending request to: $url');
        print(
            'Day $day workouts: ${jsonEncode(dayWorkouts.map((w) => w.toJson()).toList())}');

        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(dayWorkouts.map((w) => w.toJson()).toList()),
        );

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode != 200) {
          throw Exception('Failed to update workouts: ${response.body}');
        }
      }
    } catch (e) {
      print('Error updating workouts: $e');
      rethrow;
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

      final response = await http.get(
        Uri.parse('$baseUrl/coach/getWorkoutResults/$studentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print("WorkoutService: Response status code: ${response.statusCode}");
        print("WorkoutService: Response data: ${response.body}");
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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
