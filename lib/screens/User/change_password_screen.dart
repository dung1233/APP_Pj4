import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/screens/trainhome.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      _showMessage("⚠️ Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (newPassword.length < 8) {
      _showMessage("⚠️ Mật khẩu mới phải có ít nhất 8 ký tự!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final box = await Hive.openBox('userBox');
      final token = box.get('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final dio = Dio();
      final response = await dio.post(
        'http://54.251.220.228:8080/trainingSouls/users/change-password',
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print("📦 Response data: ${response.data}"); // Debug print

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API trả về token trực tiếp dưới dạng string
        if (response.data != null) {
          final newToken = response.data.toString();
          await box.put('token', newToken);
        }

        _showMessage("✅ Đổi mật khẩu thành công!", isSuccess: true);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const Trainhome(initialIndex: 4)),
            (route) => false,
          );
        }
      } else if (response.statusCode == 401) {
        print("❌ Token không hợp lệ hoặc đã hết hạn");
        _showMessage("❌ Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!");
      } else {
        print("❌ Lỗi server: ${response.statusCode}");
        _showMessage("❌ Có lỗi xảy ra. Vui lòng thử lại sau!");
      }
    } catch (e) {
      print("❌ Lỗi khi đổi mật khẩu: $e");
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          _showMessage("❌ Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!");
        } else {
          _showMessage("❌ Mật khẩu cũ không đúng!");
        }
      } else {
        _showMessage("❌ Có lỗi xảy ra. Vui lòng thử lại sau!");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đổi mật khẩu"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu cũ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}
