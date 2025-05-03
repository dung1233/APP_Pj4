import 'package:training_souls/models/item.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:training_souls/models/user_data.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://54.251.220.228:8080/trainingSouls")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/users/save-profile")
  Future<void> sendUserData(@Body() UserData userData);

  @POST("/workout/generate")
  Future<List<Workout>> generateWorkout(@Body() UserData userData);

  @GET("/workout")
  Future<List<Workout>> getWorkouts(@Header("Authorization") String token);

  @GET("/items")
  Future<List<Item>> getItems();

  @POST("/purchase/{itemId}")
  Future<void> purchaseItem(
    @Path("itemId") int itemId,
    @Header("Authorization") String token,
  );
  @POST("/purchase/complete")
  Future<void> confirmPayment(
      @Body() Map<String, dynamic> body,
      @Header("Authorization") String token,
  );

}
