import 'package:flutter/material.dart';
import 'package:training_souls/api/auth_service.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/models/login_request.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _token;
  String? get token => _token;

  final AuthService _authService; // API Service

  AuthProvider(this._authService);

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // 🔄 Cập nhật UI

    try {
      final response = await _authService
          .login(LoginRequest(email: email, password: password));

      print("📡 API Response: ${response.token}");

      if (response.token != null) {
        await LocalStorage.saveToken(response.token!);
        _token = response.token!;
        notifyListeners();
        print("🔑 Token đã lưu: $_token");
      } else {
        throw Exception("API không trả về token!");
      }
    } catch (e) {
      print("❌ Lỗi đăng nhập: $e");
    }

    _isLoading = false;
    notifyListeners(); // 🔄 Cập nhật lại UI
  }
}
