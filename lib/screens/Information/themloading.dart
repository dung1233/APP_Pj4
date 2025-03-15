import 'package:app/data/local.dart';
import 'package:app/screens/trainhome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ThemLoadingScreen extends StatelessWidget {
  const ThemLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tự động kiểm tra và chuyển hướng khi build
    Future.delayed(Duration(seconds: 10), () async {
      final userData = await LocalStorage.loadUserData();
      if (kDebugMode) {
        print('Dữ liệu đọc được: $userData');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Trainhome(
            userData: userData,
          ),
        ),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset("assets/img/Animation_1740914934240.json"),
            ),
            Text('Đang chuẩn bị bài tập...'),
          ],
        ),
      ),
    );
  }
}
