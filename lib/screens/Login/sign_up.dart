import 'package:training_souls/APi/user_service.dart';
import 'package:training_souls/screens/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/models/register_request.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("⚠️ Vui lòng nhập đầy đủ thông tin!");
      return;
    }
    if (password != confirmPassword) {
      _showMessage("⚠️ Mật khẩu nhập lại không khớp!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      final userService = UserService(dio);
      final request =
          RegisterRequest(name: name, email: email, password: password);

      print("📤 Gửi request đến: ${dio.options.baseUrl}/create-user");
      print("📜 Dữ liệu gửi đi: ${request.toJson()}");

      final response = await userService.register(request);
      print("✅ Đăng ký thành công: ${response.toJson()}");

      // 🎉 Hiển thị thông báo thành công
      _showMessage("🎉 Đăng ký thành công!", isSuccess: true);

      // ⏳ Chuyển về màn hình đăng nhập sau 2 giây
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      });
    } catch (e) {
      print("❌ Lỗi khi đăng ký: $e");
      _showMessage("❌ Đăng ký thất bại. Vui lòng thử lại!");
    } finally {
      setState(() => _isLoading = false);
    }
  }

// Hàm hiển thị thông báo
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Tiêu đề
              const Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text('Nhập thông tin để đăng ký',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 40),

              // Họ và tên
              _buildTextField(
                  controller: _nameController,
                  hint: 'Họ và tên',
                  icon: Icons.person_outline),
              const SizedBox(height: 20),

              // Email
              _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined),
              const SizedBox(height: 20),

              // Mật khẩu
              _buildTextField(
                  controller: _passwordController,
                  hint: 'Mật khẩu',
                  icon: Icons.lock_outline,
                  isPassword: true),
              const SizedBox(height: 20),

              // Xác nhận mật khẩu
              _buildTextField(
                  controller: _confirmPasswordController,
                  hint: 'Nhập lại mật khẩu',
                  icon: Icons.lock_reset,
                  isPassword: true),
              const SizedBox(height: 30),

              // Nút Đăng ký
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
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đăng ký'),
                ),
              ),
              const SizedBox(height: 20),

              // Nút chuyển về Login
              TextButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen())),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600]),
                    children: const [
                      TextSpan(text: 'Đã có tài khoản? '),
                      TextSpan(
                        text: 'Đăng nhập ngay',
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
