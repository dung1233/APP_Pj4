import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:training_souls/models/login_request.dart';
import 'package:training_souls/models/login_response.dart';

part 'auth_service.g.dart'; // ✅ File sinh tự động

@RestApi(baseUrl: "http://54.251.220.228:8080/trainingSouls/auth")
abstract class AuthService {
  factory AuthService(Dio dio, {String baseUrl}) = _AuthService;

  @POST("/login") // ✅ API Login
  Future<LoginResponse> login(@Body() LoginRequest request);
}
