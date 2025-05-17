import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:training_souls/models/user_response.dart';

part 'notification_service.g.dart';

@RestApi(baseUrl: "http://54.251.220.228:8080/trainingSouls/notifications")
abstract class NotificationService {
  factory NotificationService(Dio dio) = _NotificationService;

  @POST("/notifyCoachLevelTest/{date}")
  Future<UserResponse> notifyCoachLevelTest(
    @Header("Authorization") String token,
    @Path("date") String date,
  );
}
