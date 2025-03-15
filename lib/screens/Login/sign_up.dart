// register_screen.dart
import 'package:app/screens/Login/login.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final VoidCallback? onLoginPressed;

  const RegisterScreen({super.key, this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),

              // Tiêu đề
              Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Nhập thông tin để đăng ký',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40),

              // Họ và tên
              _buildTextField(
                hint: 'Họ và tên',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 20),

              // Email
              _buildTextField(
                hint: 'Email',
                icon: Icons.email_outlined,
              ),
              SizedBox(height: 20),

              // Mật khẩu
              _buildTextField(
                hint: 'Mật khẩu',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              SizedBox(height: 20),

              // Xác nhận mật khẩu
              _buildTextField(
                hint: 'Nhập lại mật khẩu',
                icon: Icons.lock_reset,
                isPassword: true,
              ),
              SizedBox(height: 30),

              // Nút Đăng ký
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Text('Đăng ký'),
                ),
              ),
              SizedBox(height: 20),

              // Nút chuyển về Login
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600]),
                    children: const [
                      TextSpan(text: 'Đã có tài khoản? '),
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: TextStyle(
                          color: Color(0xFF5E35B1),
                          fontWeight: FontWeight.bold,
                        ),
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
      {required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
