import 'package:app/hive_service.dart';
import 'package:app/models/work_out.dart'; // Import đúng model
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app/screens/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive(); // Khởi tạo Hive
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
