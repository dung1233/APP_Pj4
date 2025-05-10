import 'package:flutter/material.dart';
import 'package:training_souls/api/auth_service.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/models/login_request.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _token;
  String? get token => _token;

  final AuthService _authService;

  AuthProvider(this._authService) {
    _loadToken(); // Tải token khi khởi tạo
  }

  // Tải token từ LocalStorage
  Future<void> _loadToken() async {
    try {
      _token = await LocalStorage.getToken();
      print("🔑 Token loaded from LocalStorage: $_token");
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi khi tải token: $e");
      _token = null;
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService
          .login(LoginRequest(email: email, password: password));

      print("📡 API Response: ${response.token}");

      if (response.token != null && response.token!.isNotEmpty) {
        await LocalStorage.saveToken(response.token!);
        _token = response.token!;
        print("🔑 Token đã lưu: $_token");
      } else {
        throw Exception("API không trả về token hợp lệ!");
      }
    } catch (e) {
      print("❌ Lỗi đăng nhập: $e");
      _token = null;
      // Xóa token nếu đăng nhập thất bại
    }

    _isLoading = false;
    notifyListeners();
  }

  // Hàm đăng xuất
}
