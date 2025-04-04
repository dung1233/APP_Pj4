import 'package:training_souls/models/work_out.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHive() async {
  try {
    await Hive.initFlutter();

    // Đăng ký adapter cho Workout
    // if (!Hive.isAdapterRegistered(0)) {
    //   Hive.registerAdapter(WorkoutAdapter());
    //   print("✅ WorkoutAdapter đã được đăng ký thành công!");
    // } else {
    //   print("⚠️ WorkoutAdapter đã được đăng ký trước đó!");
    // }

    // Mở box 'workoutbox' nếu chưa mở
    if (!Hive.isBoxOpen('workoutbox')) {
      await Hive.openBox<Workout>('workoutbox');
      print("✅ Box 'workoutbox' đã được mở thành công!");
    } else {
      print("⚠️ Box 'workoutbox' đã được mở trước đó!");
    }

    // Mở box 'userBox' nếu chưa mở
    if (!Hive.isBoxOpen('userBox')) {
      await Hive.openBox('userBox');
      print("✅ Box 'userBox' đã được mở thành công!");
    } else {
      print("⚠️ Box 'userBox' đã được mở trước đó!");
    }

    print("✅ Hive đã được khởi tạo thành công!");
  } catch (e) {
    print("❌ Lỗi khi khởi tạo Hive: $e");
  }
}
