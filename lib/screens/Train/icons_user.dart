import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/api/user_service.dart';
import 'package:training_souls/data/local_storage.dart';

import '../../Stripe/UpgradeAccountPage.dart';
import '../../Stripe/account_type_dialog.dart';

class IconsUser extends StatefulWidget {
  const IconsUser({super.key});

  @override
  _IconsUserState createState() => _IconsUserState();
}

class _IconsUserState extends State<IconsUser>
    with AutomaticKeepAliveClientMixin<IconsUser> {
  String? userName;
  bool isLoading = true;
  Map<String, dynamic> _userInfo = {};

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final token = await LocalStorage.getValidToken();

    if (token == null) {
      print("❌ Không có token hợp lệ");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final dio = Dio();
    final client = UserService(dio);

    try {
      final response = await client.getMyInfo("Bearer $token");
      print("📌 API Response: ${response.toJson()}");

      if (response.code == 0) {
        final user = response.result;
        print("📌 User data: ${user.toJson()}");

        setState(() {
          userName = user.name;
          _userInfo = {
            'userID': user.userID,
            'name': user.name,
            'email': user.email,
            'accountType': user.accountType,
            'points': user.points,
            'level': user.level
          };
          isLoading = false;
        });
      } else {
        print("❌ API trả về mã lỗi: ${response.code}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String capitalize(String? text) {
    if (text == null || text.isEmpty) return "Basic";
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  LinearGradient getAccountGradient(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'premium':
        return const LinearGradient(
          colors: [Colors.orange, Colors.black],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFF191414)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      refreshUser();
    }
  }

  void refreshUser() {
    fetchUserInfo();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final accountTypeRaw = _userInfo['accountType'] ?? 'basic';
    final accountType = capitalize(accountTypeRaw);

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 22, right: 20),
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Chào Mừng Trở Lại, ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: userName ?? 'aa',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                showGeneralDialog(
                  context: context,
                  barrierLabel: 'Dismiss',
                  barrierColor: Colors.black.withOpacity(0.5),
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) {
                    return AccountTypePopup(
                      selectedOption: accountType,
                      options: ['Basic', 'Premium'],
                      onSelected: (selectedType) {
                        print("🔶 Người dùng đã chọn gói: $selectedType");
                      },
                    );
                  },
                  transitionBuilder: (_, animation, __, child) {
                    return Transform.scale(
                      scale: animation.value,
                      child: Opacity(
                        opacity: animation.value,
                        child: child,
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: getAccountGradient(accountTypeRaw),
                ),
                child: Text(
                  accountType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}