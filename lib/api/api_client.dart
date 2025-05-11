import 'package:dio/dio.dart';
import 'package:training_souls/api/api_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final ApiService service;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    final dio = Dio();
    service = ApiService(dio);
  }
}
