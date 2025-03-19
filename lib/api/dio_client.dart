import 'package:dio/dio.dart';
import 'package:app/data/local_storage.dart';
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
          // 🟢 Lấy token từ LocalStorage
          String? token = await LocalStorage.getToken();
          if (kDebugMode) {
            print("📡 Token gửi đi: $token");
          }

          // Nếu có token, thêm vào headers
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options); // Gửi request đi
        },
      ),
    );

  static Dio get dio => _dio;
}
