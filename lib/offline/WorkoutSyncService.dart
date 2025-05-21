import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data/DatabaseHelper.dart';

class WorkoutSyncService {
  static final WorkoutSyncService _instance = WorkoutSyncService._internal();
  factory WorkoutSyncService() => _instance;
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio();
  final _syncQueueBox = 'syncQueueBox';
  final dbHelper = DatabaseHelper();

  // Stream controller để thông báo thay đổi trạng thái đồng bộ
  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get syncStatusStream => _syncStatusController.stream;

  // Lưu trữ instance của box
  Box<Map>? _box;

  WorkoutSyncService._internal();

  // Lấy instance của box
  Future<Box<Map>> get _getBox async {
    if (_box == null) {
      _box = await Hive.openBox<Map>(_syncQueueBox);
    }
    return _box!;
  }

  // Khởi tạo service, gọi trong main.dart
  Future<void> init() async {
    try {
      // Đảm bảo box sync queue đã được tạo
      _box = await Hive.openBox<Map>(_syncQueueBox);

      // Lắng nghe sự thay đổi kết nối
      _connectivity.onConnectivityChanged
          .listen((ConnectivityResult result) async {
        if (result != ConnectivityResult.none) {
          // Khi có kết nối internet trở lại, thử đồng bộ dữ liệu
          final hasPendingData = await hasPendingSync();
          if (hasPendingData) {
            _syncStatusController.add(true);
            await syncPendingData();
          }
        }
      });

      // Kiểm tra ngay khi khởi tạo
      final hasPendingData = await hasPendingSync();
      if (hasPendingData) {
        _syncStatusController.add(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print("[SYNC] ❌ Lỗi khởi tạo service: $e");
      }
    }
  }

  // Kiểm tra kết nối mạng
  Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Thêm dữ liệu vào hàng đợi đồng bộ
  Future<void> addToSyncQueue(
      int dayNumber, List<Map<String, dynamic>> results) async {
    try {
      final box = await _getBox;
      // Tạo một unique key dựa trên ngày và timestamp
      String key = 'day_${dayNumber}_${DateTime.now().millisecondsSinceEpoch}';

      // Lưu dữ liệu cần đồng bộ
      await box.put(key, {
        'dayNumber': dayNumber,
        'results': results,
        'timestamp': DateTime.now().toIso8601String(),
        'syncAttempts': 0
      });

      if (kDebugMode) {
        print("[SYNC] ✅ Đã thêm dữ liệu ngày $dayNumber vào hàng đợi đồng bộ");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[SYNC] ❌ Lỗi khi thêm vào hàng đợi: $e");
      }
    }
  }

  // Đồng bộ dữ liệu từ hàng đợi
  Future<bool> syncPendingData() async {
    final db = await dbHelper.database;
    // Kiểm tra kết nối
    final hasConnection = await isConnected();
    if (!hasConnection) {
      if (kDebugMode) {
        print("[SYNC] ⚠️ Không có kết nối mạng, bỏ qua đồng bộ");
      }
      return false;
    }

    try {
      final box = await _getBox;
      if (box.isEmpty) {
        if (kDebugMode) {
          print("[SYNC] ℹ️ Không có dữ liệu cần đồng bộ");
        }
        _syncStatusController.add(false);
        return true;
      }

      // Lấy danh sách khóa cần đồng bộ
      final keys = box.keys.toList();
      bool allSuccess = true;

      // Lặp qua từng item và thử đồng bộ
      for (var key in keys) {
        final item = box.get(key);
        if (item == null) continue;

        try {
          // Chuyển đổi dữ liệu sang đúng định dạng
          final Map<String, dynamic> data = Map<String, dynamic>.from(item);
          final int dayNumber = data['dayNumber'] as int;
          final List<dynamic> resultsList = data['results'] as List<dynamic>;
          final List<Map<String, dynamic>> results = resultsList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          print("[SYNC] 🔄 Đang đồng bộ dữ liệu cho ngày $dayNumber");
          print("[SYNC] 📊 Số lượng kết quả: ${results.length}");

          bool success = await sendToApiOffline(dayNumber, results);
          if (success) {
            // Nếu đồng bộ thành công, xóa khỏi hàng đợi
            await box.delete(key);
            // Nếu thành công, xóa dữ liệu local
            await db.delete('workout_results',
                where: 'day_number = ?', whereArgs: [dayNumber]);
            if (kDebugMode) {
              print("[SYNC] ✅ Đồng bộ thành công dữ liệu: $key");
            }
          } else {
            // Tăng số lần thử đồng bộ
            data['syncAttempts'] = (data['syncAttempts'] ?? 0) + 1;
            await box.put(key, data);
            allSuccess = false;
            if (kDebugMode) {
              print(
                  "[SYNC] ⚠️ Đồng bộ thất bại dữ liệu: $key, lần thử: ${data['syncAttempts']}");
            }
          }
        } catch (e) {
          // Xử lý lỗi khi đồng bộ
          allSuccess = false;
          if (kDebugMode) {
            print("[SYNC] ❌ Lỗi khi đồng bộ dữ liệu $key: $e");
          }
        }
      }

      // Cập nhật trạng thái đồng bộ
      _syncStatusController.add(!allSuccess);
      return allSuccess;
    } catch (e) {
      if (kDebugMode) {
        print("[SYNC] ❌ Lỗi khi đồng bộ dữ liệu: $e");
      }
      _syncStatusController.add(true);
      return false;
    }
  }

  // Gửi dữ liệu lên API
  Future<bool> sendToApiOffline(
      int dayNumber, List<Map<String, dynamic>> results) async {
    try {
      final box = await Hive.openBox('userBox');
      final token = box.get('token');

      if (token == null) {
        debugPrint("[SYNC] ❌ Token không tồn tại");
        return false;
      }

      // Định dạng lại dữ liệu theo yêu cầu của API
      final Map<String, dynamic> apiData = {
        "dayNumber": dayNumber,
        "results": results
            .map((result) => {
                  "exerciseName": result['exerciseName']?.toString(),
                  "setsCompleted": result['setsCompleted'] is int
                      ? result['setsCompleted']
                      : int.tryParse(
                              result['setsCompleted']?.toString() ?? '0') ??
                          0,
                  "repsCompleted": result['repsCompleted'] is int
                      ? result['repsCompleted']
                      : int.tryParse(
                              result['repsCompleted']?.toString() ?? '0') ??
                          0,
                  "distanceCompleted": result['distanceCompleted'] is double
                      ? result['distanceCompleted']
                      : double.tryParse(
                              result['distanceCompleted']?.toString() ??
                                  '0.0') ??
                          0.0,
                  "durationCompleted": result['durationCompleted'] is int
                      ? result['durationCompleted']
                      : int.tryParse(
                              result['durationCompleted']?.toString() ?? '0') ??
                          0
                })
            .toList()
      };

      debugPrint("[SYNC] 📤 Gửi dữ liệu lên API: $apiData");

      final response = await _dio.post(
        'http://54.251.220.228:8080/trainingSouls/workout/workout-results',
        data: apiData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("[SYNC] ✅ Gửi API thành công");

        return true;
      } else {
        debugPrint(
            "[SYNC] ❌ Lỗi API: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      debugPrint("[SYNC] ❌ Lỗi kết nối API: $e");
      return false;
    }
  }

  // Kiểm tra xem có dữ liệu đang chờ đồng bộ không
  Future<bool> hasPendingSync() async {
    try {
      final box = await _getBox;
      return box.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("[SYNC] ❌ Lỗi kiểm tra dữ liệu đang chờ: $e");
      }
      return false;
    }
  }

  // Lấy số lượng dữ liệu đang chờ đồng bộ
  Future<int> getPendingSyncCount() async {
    try {
      final box = await _getBox;
      return box.length;
    } catch (e) {
      if (kDebugMode) {
        print("[SYNC] ❌ Lỗi lấy số lượng dữ liệu đang chờ: $e");
      }
      return 0;
    }
  }

  // Xóa toàn bộ dữ liệu và đóng box
  Future<void> clearAllData() async {
    try {
      final box = await _getBox;
      await box.clear();
      await box.close();
      _box = null;
      if (kDebugMode) {
        print("[SYNC] ✅ Đã xóa toàn bộ dữ liệu đồng bộ");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[SYNC] ❌ Lỗi khi xóa dữ liệu đồng bộ: $e");
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _syncStatusController.close();
    _box?.close();
  }
}
