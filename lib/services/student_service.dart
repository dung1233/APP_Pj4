import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:training_souls/models/student_model.dart';

class StudentService {
  static const String baseUrl = 'http://54.251.220.228:8080/trainingSouls';

  Future<List<Student>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coach/students'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }
}
