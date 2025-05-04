import 'package:training_souls/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

import 'package:training_souls/api/auth_service.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/providers/auth_provider.dart';
import 'package:training_souls/providers/workout_data_service.dart';
import 'package:training_souls/providers/workout_provider.dart';
import 'package:training_souls/hive_service.dart';
import 'package:training_souls/screens/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Khởi tạo Hive
  await Hive.initFlutter();
  await initHive(); // Nếu có hàm khởi tạo thêm

  // ✅ Khởi tạo SQLite nếu cần (không cần chờ vì SQLite tự động mở khi gọi database)

  final dio = Dio(); // Khởi tạo Dio để dùng trong API

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                AuthProvider(AuthService(dio))), // Provider đăng nhập
        ChangeNotifierProvider(
            create: (context) => WorkoutProvider(ApiService(dio))),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => WorkoutDataService()), // Provider bài tập
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      home: HomePage(), // Trang Home chính
    );
  }
}
