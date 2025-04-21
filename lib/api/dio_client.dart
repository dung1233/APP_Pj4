import 'package:dio/dio.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://54.251.220.228:8080/trainingSouls",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await LocalStorage.getToken();
          if (token?.isNotEmpty ?? false) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("📩 API Response: ${response.data}");
          }
          handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            if (kDebugMode) {
              print("🔴 Token hết hạn, đăng xuất!");
            }
            // TODO: Xử lý đăng xuất
          } else {
            if (kDebugMode) {
              print("⚠️ Lỗi API: ${e.message}");
            }
          }
          handler.next(e);
        },
      ),
    );

  static Dio get dio => _dio;
  static Dio dioWithToken(String token) {
    final dioWithToken = Dio(
      BaseOptions(
        baseUrl: "http://54.251.220.228:8080/trainingSouls",
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ),
    );
    return dioWithToken;
  }
}
