import 'package:app/screens/Login/sign_up.dart';
import 'package:app/screens/Information/data.dart';

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'Chào mừng',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Đăng nhập để tiếp tục',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),

            // Email Field
            _buildTextField(
              hint: 'Email',
              icon: Icons.email_outlined,
              isPassword: false,
            ),
            SizedBox(height: 20),

            // Password Field
            _buildTextField(
              hint: 'Mật khẩu',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            SizedBox(height: 24),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5E35B1), // Màu tím nhạt
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Datascreen()));
                },
                child: Text('Đăng nhập'),
              ),
            ),
            SizedBox(height: 20),
            // Footer
            TextButton(
              onPressed: () {},
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()));
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600]),
                  children: const [
                    TextSpan(text: 'Chưa có tài khoản? '),
                    TextSpan(
                      text: 'Đăng ký ngay',
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
