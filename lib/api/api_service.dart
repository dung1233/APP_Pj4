import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/models/item.dart';
import 'package:training_souls/models/post.dart';
import 'package:training_souls/models/rank.dart';
import 'package:training_souls/models/work_history.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/models/user_data.dart';

part 'api_service.g.dart';

// Sử dụng ApiService hiện có từ dự án của bạn
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
  Future<String> purchaseItem(
    @Path("itemId") int itemId,
    @Header("Authorization") String token,
  );

  @POST("/purchase/complete")
  Future<void> confirmPayment(
    @Body() Map<String, dynamic> body,
    @Header("Authorization") String token,
  );
  @POST("/purchase/stripeCompleted")
  Future<void> StripePayment(
      @Body() Map<String, dynamic> body,
      @Header("Authorization") String token,
  );

  @GET("/workout/history")
  Future<List<WorkoutHistory>> getWorkoutHistory(
    @Header("Authorization") String token,
  );

  @GET("/posts/getAllPost")
  Future<List<Post>> getAllPosts();

  @GET("/ranks")
  Future<List<Rank>> getRanks();

  @POST("/checkin")
  Future<String> postCheckIn(@Header("Authorization") String token);

  @POST("/reward")
  Future<String> claimRewards(@Header("Authorization") String token);
  @GET("/users/getMyPurchasedItem")
  Future<Response> getPurchasedItems(
      @Header("Authorization") String token,
      );
}
