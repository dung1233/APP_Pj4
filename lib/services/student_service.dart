import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training_souls/models/student_model.dart';
import 'package:training_souls/models/workout_result_model.dart';

class StudentService {
  static const String baseUrl = 'http://54.251.220.228:8080/trainingSouls';

  Future<List<Student>> getStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Token: $token');
      print('Request URL: $baseUrl/coach/students');

      final response = await http.get(
        Uri.parse('$baseUrl/coach/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('Raw API Response: $data');
        final students = data.map((json) {
          print('Processing student JSON: $json');
          print('userID type: ${json['userID']?.runtimeType}');
          print('userID value: ${json['userID']}');
          final student = Student.fromJson(json);
          print('Parsed student: ${student.toJson()}');
          return student;
        }).toList();
        print('Total students parsed: ${students.length}');
        return students;
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getStudents: $e');
      throw Exception('Failed to load students: $e');
    }
  }

  Future<bool> confirmLevelUp(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/coach/coachConfirmLevelUp/$userId';
      print('Confirming level up for user: $userId');
      print('Full Request URL: $url');
      print('Using token: $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found. Please check the URL: $url');
      } else {
        throw Exception(
            'Failed to confirm level up: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in confirmLevelUp: $e');
      throw Exception('Failed to confirm level up: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentProfile(String studentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/coach/getStudentProfile/$studentId';
      print('Fetching student profile for ID: $studentId');
      print('Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
            'Failed to load student profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getStudentProfile: $e');
      throw Exception('Failed to load student profile: $e');
    }
  }

  Future<List<WorkoutResult>> getWorkoutHistory(String studentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/coach/getWorkoutResults/$studentId';
      print('Fetching workout history for student ID: $studentId');
      print('Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the response body using UTF-8
        final String decodedBody = utf8.decode(response.bodyBytes);
        print('Decoded Response Body: $decodedBody');

        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => WorkoutResult.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load workout history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getWorkoutHistory: $e');
      throw Exception('Failed to load workout history: $e');
    }
  }
}
