import 'package:app/models/work_out.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:app/screens/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    Hive.registerAdapter(WorkoutAdapter());

    // Xóa box cũ nếu cần
    if (await Hive.boxExists('workoutbox')) {
      await Hive.deleteBoxFromDisk('workoutbox');
    }

    // ✅ Sửa kiểu dữ liệu khi mở box
    await Hive.openBox<Workout>(
        'workoutbox'); // 🛠️ Mở Box chứa đối tượng Workout
    await Hive.openBox('userBox');
  } catch (e) {
    print('Lỗi khi khởi tạo Hive: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter',
      home: HomePage(),
    );
  }
}
