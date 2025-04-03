import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/trainhome.dart';

import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

class Localloading extends StatefulWidget {
  const Localloading({super.key});

  @override
  State<Localloading> createState() => _LocalloadingState();
}

class _LocalloadingState extends State<Localloading> {
  bool _isLoading = true; // ✅ Biến để hiển thị loading
  @override
  void initState() {
    super.initState();
    _loadDataFromSQLite();
  }

  Future<void> _loadDataFromSQLite() async {
    final dbHelper = DatabaseHelper(); // 🛠 Sử dụng DatabaseHelper
    final List<Workout> allWorkouts =
        await dbHelper.getWorkouts(); // 📦 Lấy dữ liệu từ SQLite

    if (allWorkouts.isEmpty) {
      print("⚠️ Không có dữ liệu trong SQLite.");
      setState(() => _isLoading = false); // ✅ Tắt loading nếu không có dữ liệu
      return;
    }

    print("✅ Đã tải ${allWorkouts.length} bài tập từ SQLite!");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Trainhome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset("assets/img/Animation_1740914934240.json"),
            ),
            const Text('Đang tải dữ liệu ....'),
          ],
        ),
      ),
    );
  }
}
