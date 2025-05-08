// ignore: depend_on_referenced_packages
import 'package:training_souls/providers/auth_provider.dart';
import 'package:training_souls/providers/user_provider.dart';
import 'package:training_souls/providers/workout_provider.dart';
import 'package:training_souls/screens/Information/data.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:training_souls/screens/Login/sign_up.dart';
import 'package:training_souls/screens/trainhome.dart';
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Thực hiện đăng nhập
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      print("✅ Đăng nhập thành công, token: ${authProvider.token}");

      // Kiểm tra xem người dùng có dữ liệu cá nhân chưa
      final hasUserData = await userProvider.checkUserData(authProvider.token!);

      if (!hasUserData) {
        // Nếu chưa có dữ liệu, chuyển hướng đến DataScreen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Datascreen()),
          );
        }
      } else {
        // Nếu đã có dữ liệu, đồng bộ danh sách bài tập
        await workoutProvider.syncWorkouts(authProvider.token!);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Trainhome()),
          );
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
