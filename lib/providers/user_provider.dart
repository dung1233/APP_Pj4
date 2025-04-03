import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  bool _hasUserData = false;

  bool get hasUserData => _hasUserData;

  // ✅ Kiểm tra xem tài khoản đã có thông tin cá nhân chưa
  Future<bool> checkUserData(String token) async {
    final url = Uri.parse(
        "http://54.251.220.228:8080/trainingSouls/users/getMyInfo"); // 🔥 API lấy dữ liệu user
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📌 API trả về: $data");

        if (data["result"] != null && data["result"]["userProfile"] != null) {
          _hasUserData = true; // Chưa có dữ liệu, chuyển sang DataScreen
        } else {
          _hasUserData = false; // Đã có dữ liệu, vào TrainHome
        }
      } else {
        _hasUserData = false;
      }

      notifyListeners();
      return _hasUserData;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Lỗi khi kiểm tra dữ liệu người dùng: $e");
      }
      return false;
    }
  }
}
