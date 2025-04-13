import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveUserData({
    String? gender, //gioi tinh
    String? level, //level chon
    String? name, //ten
    int? age, // tuoi
    int? cm, //chieu cao
    int? kg, // can nang
    String? activity, //muc do hoat dong
    String? fitness, // muc tieu chinh
    String? medical, //tinh trang suc khoe
    // String? diet, //che don an chay hoac bth
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy dữ liệu cũ nếu có
    final existingData = await loadUserData();

    // Cập nhật dữ liệu mới mà không làm mất dữ liệu cũ
    final newData = {
      "gender": gender ??
          existingData["gender"], // Giữ giá trị cũ nếu không có giá trị mới
      "level": level ?? existingData["level"],
      "name": name ?? existingData["name"],
      "age": age ?? existingData["age"],
      "cm": cm ?? existingData["cm"],
      "kg": kg ?? existingData["kg"],
      "activity": activity ?? existingData["activity"],
      "fitness": fitness ?? existingData["fitness"],
      "medical": medical ?? existingData["medical"],
      // "diet": diet ?? existingData["diet"],
    };

    await prefs.setString("userData", jsonEncode(newData));
  }

  static Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("userData");

    if (data != null) {
      return jsonDecode(data);
    }

    return {}; // Trả về map rỗng nếu chưa có dữ liệu
  }
}
