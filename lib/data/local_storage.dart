import 'package:hive/hive.dart';

class LocalStorage {
  static Future<void> saveUserData({
    String? gender,
    int? age,
    int? height,
    int? weight,
    required String activity_level,
    required String fitness_goal,
    required String medical_conditions,
    String? level,
  }) async {
    var box = await Hive.openBox('userBox');
    final existingData = await loadUserData();

    // Kiểm tra cả null và chuỗi rỗng
    final newData = {
      "gender": gender ?? existingData["gender"],
      "age": age ?? existingData["age"],
      "height": height ?? existingData["height"],
      "weight": weight ?? existingData["weight"],
      "activity_level": (activity_level.isEmpty)
          ? (existingData["activity_level"] ?? "Not specified")
          : activity_level,
      "fitness_goal": (fitness_goal.isEmpty)
          ? (existingData["fitness_goal"] ?? "Not specified")
          : fitness_goal,
      "medical_conditions": (medical_conditions.isEmpty)
          ? (existingData["medical_conditions"] ?? "None")
          : medical_conditions,
      "level": level ?? existingData["level"],
    };

    await box.put('userData', newData);
  }

  static Future<Map<String, dynamic>> loadUserData() async {
    final box = await Hive.openBox('userBox');
    final data = box.get('userData');
    print("📌 Dữ liệu lấy từ Hive: $data");

    if (data != null) {
      final Map<String, dynamic> userData = Map<String, dynamic>.from(data);

      // Kiểm tra và gán giá trị mặc định nếu rỗng
      userData["activity_level"] = (userData["activity_level"]?.isEmpty ?? true)
          ? "Not specified"
          : userData["activity_level"];
      userData["fitness_goal"] = (userData["fitness_goal"]?.isEmpty ?? true)
          ? "Not specified"
          : userData["fitness_goal"];
      userData["medical_conditions"] =
          (userData["medical_conditions"]?.isEmpty ?? true)
              ? "None"
              : userData["medical_conditions"];

      return userData;
    }
    return {}; // Trả về map rỗng nếu chưa có dữ liệu
  }

  static Future<void> saveToken(String token) async {
    var box = await Hive.openBox('userBox');
    await box.put('token', token);
    print("✅ Token đã được lưu: $token");
  }

  static Future<String?> getToken() async {
    var box = await Hive.openBox('userBox');
    return box.get('token');
  }
}
