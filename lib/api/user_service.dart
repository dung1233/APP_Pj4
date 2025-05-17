import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:training_souls/models/register_request.dart';
import 'package:training_souls/models/register_response.dart';
import 'package:training_souls/models/user_response.dart';

part 'user_service.g.dart'; // ✅ File sinh tự động

@RestApi(baseUrl: "http://54.251.220.228:8080/trainingSouls/users")
abstract class UserService {
  factory UserService(Dio dio, {String baseUrl}) = _UserService;

  @POST("/create-user") // ✅ API Đăng ký
  Future<RegisterResponse> register(@Body() RegisterRequest request);

  @GET("/getMyInfo")
  Future<UserResponse> getMyInfo(@Header("Authorization") String token);

  @POST("/select-coach/:coachId")
  Future<void> selectCoach(
    @Header("Authorization") String token,
    @Path() String coachId,
  );
}
