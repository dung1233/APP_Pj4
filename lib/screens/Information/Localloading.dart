import 'package:app/models/work_out.dart';
import 'package:app/screens/trainhome.dart';
<<<<<<< HEAD

=======
import 'package:flutter/foundation.dart';
>>>>>>> 183d0011fe4e1a857f05800298f57c19850082a2
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

class Localloading extends StatefulWidget {
  const Localloading({super.key});

  @override
  State<Localloading> createState() => _LocalloadingState();
}

class _LocalloadingState extends State<Localloading> {
  @override
  void initState() {
    super.initState();
    _loadDataFromHive();
  }

  /// ✅ Lấy dữ liệu từ Hive
  Future<void> _loadDataFromHive() async {
    // 📦 Kiểm tra box đã mở chưa, nếu chưa thì mở
    if (!Hive.isBoxOpen('workouts')) {
      await Hive.openBox<Workout>('workouts');
    }

    final workoutBox = Hive.box<Workout>('workouts');

    if (workoutBox.isNotEmpty) {
      print('✅ Đã tải ${workoutBox.length} bài tập từ Hive!');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Trainhome()),
        );
      }
    } else {
      print('⚠️ Không có dữ liệu trong Hive!');
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
            const Text('Đang tải dữ liệu từ Hive...'),
          ],
        ),
      ),
    );
  }
}
