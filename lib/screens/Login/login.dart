import 'package:app/APi/auth_service.dart';
import 'package:app/data/local_storage.dart';
import 'package:app/models/login_request.dart';
import 'package:app/screens/Login/sign_up.dart';
import 'package:app/screens/Information/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Biến để hiển thị trạng thái loading

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm gọi API Login
  Future<void> _login() async {
    setState(() => _isLoading = true); // Bật loading

    try {
      final dio = Dio();
      final authService = AuthService(dio);
      final request = LoginRequest(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final response = await authService.login(request);
      if (kDebugMode) {
        print("📩 Phản hồi từ API: ${response.toJson()}");
      } // Kiểm tra dữ liệu trả về

      if (response.token != null && response.token!.isNotEmpty) {
        // ✅ Lưu token vào SharedPreferences
        await LocalStorage.saveToken(response.token!);
        if (kDebugMode) {
          print("🔑 Token đã lưu: ${response.token}");
        }

        // 👉 Chuyển hướng sau khi đăng nhập thành công
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => Datascreen()),
        );
      } else {
        if (kDebugMode) {
          print("⚠️ Không nhận được token từ API!");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Lỗi đăng nhập: $e");
      }
    }

    setState(() => _isLoading = false); // Tắt loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chào mừng',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Đăng nhập để tiếp tục',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 15),
            _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined),
            const SizedBox(height: 10),
            _buildTextField(
                controller: _passwordController,
                hint: 'Mật khẩu',
                icon: Icons.lock_outline,
                isPassword: true),

            const SizedBox(height: 24),

            // Nút đăng nhập
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E35B1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading
                    ? null
                    : _login, // Nếu đang loading thì disable button
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đăng nhập'),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {},
              child: Text('Quên mật khẩu?',
                  style: TextStyle(
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600]),
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    TextSpan(text: 'Chưa có tài khoản? '),
                    TextSpan(
                      text: 'Đăng ký ngay',
                      style: TextStyle(
                          color: Color(0xFF5E35B1),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
