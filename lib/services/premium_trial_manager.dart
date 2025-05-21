import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/popup/premium_required_popup.dart';
import 'package:training_souls/Stripe/account_type_dialog.dart';
import 'package:training_souls/models/work_out.dart';

import '../APi/user_service.dart';
import 'package:training_souls/data/local_storage.dart';

class PremiumTrialManager {
  // Kiểm tra xem người dùng có tài khoản premium hay không
  static Future<bool> isPremiumUser() async {
    try {
      final token = await LocalStorage.getValidToken();
      if (token == null) {
        throw Exception("Token không tồn tại");
      }

      final dio = Dio();
      final client = UserService(dio);
      final response = await client.getMyInfo("Bearer $token");

      if (response.code == 0 && response.result != null) {
        final accountType = response.result?.accountType?.toLowerCase() ?? 'basic';
        return accountType == 'premium';
      }

      return false;
    } catch (e) {
      print("❌ Lỗi khi kiểm tra loại tài khoản: $e");
      return false;
    }
  }

  // Kiểm tra xem thời gian dùng thử đã hết chưa
  static Future<bool> isTrialExpired() async {
    try {
      // Kiểm tra xem người dùng có tài khoản premium không
      final hasPremium = await isPremiumUser();

      // Nếu người dùng có tài khoản premium, không cần kiểm tra thời gian dùng thử
      if (hasPremium) {
        return false;
      }
      final dbHelper = DatabaseHelper();
      final List<Workout> allWorkouts = await dbHelper.getWorkouts();

      if (allWorkouts.isEmpty) {
        return false;
      }

      // Xác định ngày bắt đầu chương trình dựa vào workoutDate
      final programStartDate = allWorkouts
          .map((e) => e.workoutDate)
          .whereType<String>()
          .map((s) => DateTime.tryParse(s))
          .whereType<DateTime>()
          .reduce((a, b) => a.isBefore(b) ? a : b);

      if (programStartDate == null) {
        return false;
      }

      // Tính số ngày đã trôi qua kể từ khi bắt đầu
      final now = DateTime.now();
      final daysPassed = now.difference(programStartDate).inDays;

      // Kiểm tra nếu đã qua 7 ngày
      return daysPassed >= 7;
    } catch (e) {
      print("❌ Lỗi khi kiểm tra thời gian dùng thử: $e");
      return false;
    }
  }

  // Kiểm tra và hiển thị popup nếu hết thời gian dùng thử
  static Future<void> checkAndShowTrialExpiredPopup(
      BuildContext context) async {
    final isExpired = await isTrialExpired();
    if (isExpired) {
      // Hiển thị popup không thể đóng
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PremiumRequiredPopup(
          onBuyPremium: () {
            Navigator.pop(context); // Đóng popup hiện tại
            showDialog(
              context: context,
              builder: (context) => AccountTypePopup(
                selectedOption: 'Basic',
                options: ['Basic', 'Premium'],
                onSelected: (selectedType) {
                  print("🔶 Người dùng đã chọn gói: $selectedType");
                },
              ),
            );
          },
        ),
      );
    }
  }


}
