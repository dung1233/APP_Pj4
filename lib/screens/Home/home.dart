import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/Home/app_bar.dart';
import 'package:training_souls/screens/Information/Localloading.dart';
import 'package:training_souls/screens/Login/login.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _nextPage() async {
    String? token = await LocalStorage.getToken();

    Widget nextScreen =
        (token != null && token.isNotEmpty) ? Localloading() : LoginScreen();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white, // Màu nền trắng như mẫu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tiêu đề
            Spacer(),
            // Ảnh banner
            Container(
              height: 300,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(
                      "assets/img/home.jpg"), // Thay bằng ảnh của bạn
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Spacer(),
            Text(
              "Training Souls",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10),

            // Dòng mô tả
            Text(
              "Let's train your souls",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            // Nút Get Started
            Spacer(),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6F00), // Màu nút
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Get started",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
