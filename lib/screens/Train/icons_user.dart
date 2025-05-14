import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/api/user_service.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
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
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    _loadUserData();
    _loadUserProfile(dbHelper);
  }

  Future<void> _loadUserData() async {
    final name = await DatabaseHelper().getUserName();
    setState(() {
      userName = name ?? 'aaa';
    });
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
    final dbHelper = DatabaseHelper();
    await dbHelper.checkAndCreateTables();

    try {
      final response = await client.getMyInfo("Bearer $token");

      // Kiểm tra code của response
      if (response.code == 0) {
        final user = response.result;

        // Lưu thông tin user vào bảng user_info
        await dbHelper.insertUserInfo({
          'userID': user.userID,
          'name': user.name,
          'email': user.email,
          'accountType': user.accountType,
          'points': user.points,
          'level': user.level
        });

        // Lưu thông tin userProfile vào bảng user_profile
        if (user.userProfile != null) {
          await dbHelper.insertUserProfile({
            'userID': user.userID,
            'gender': user.userProfile.gender,
            'age': user.userProfile.age,
            'height': user.userProfile.height,
            'weight': user.userProfile.weight,
            'bmi': user.userProfile.bmi,
            'bodyFatPercentage': user.userProfile.bodyFatPercentage,
            'muscleMassPercentage': user.userProfile.muscleMassPercentage,
            'activityLevel': user.userProfile.activityLevel,
            'fitnessGoal': user.userProfile.fitnessGoal,
            'level': user.userProfile.level,
            'strength': user.userProfile.strength,
            'deathPoints': user.userProfile.deathPoints,
            'agility': user.userProfile.agility,
            'endurance': user.userProfile.endurance,
            'health': user.userProfile.health,
          });
        }

        // // Lưu thông tin roles và permissions
        // if (user.roles != null && user.roles.isNotEmpty) {
        //   for (var role in user.roles) {
        //     // Lưu role
        //     int roleID = await dbHelper.insertRole({
        //       'userID': user.userID,
        //       'name': role.name,
        //       'description': role.description,
        //     });

        //     // Lưu permissions của role
        //     if (role.permissions != null && role.permissions.isNotEmpty) {
        //       for (var permission in role.permissions) {
        //         await dbHelper.insertPermission({
        //           'roleID': roleID,
        //           'name': permission.name,
        //           'description': permission.description,
        //         });
        //       }
        //     }
        //   }
        // }

        // Kiểm tra dữ liệu đã lưu bằng cách truy vấn từ database và print ra console
        _printDatabaseContent(dbHelper);

        setState(() {
          userName = user.name;
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

  Future<void> _printDatabaseContent(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;

    // Lấy và in thông tin người dùng
    final userInfo = await db.query('user_info');
    print("❓ Dữ liệu bảng user_info:");
    userInfo.forEach((user) {
      print(user);
    });

    // Lấy và in thông tin user_profile
    final userProfiles = await db.query('user_profile');
    print("❓ Dữ liệu bảng user_profile:");
    userProfiles.forEach((profile) {
      print(profile);
    });

    // // Lấy và in thông tin roles
    // final roles = await db.query('roles');
    // print("❓ Dữ liệu bảng roles:");
    // roles.forEach((role) {
    //   print(role);
    // });

    // // Lấy và in thông tin permissions
    // final permissions = await db.query('permissions');
    // print("❓ Dữ liệu bảng permissions:");
    // permissions.forEach((permission) {
    //   print(permission);
    // });
  }

  // premium
  Future<void> _loadUserProfile(DatabaseHelper dbHelper) async {
    try {

      // Then try to fetch fresh data from API
      final token = await LocalStorage.getValidToken();
      if (token != null) {
        final dio = Dio();
        final client = UserService(dio);

        try {
          final response = await client.getMyInfo("Bearer $token");
          if (response.code == 0) {
            final user = response.result;
            // Update local database
            await dbHelper.insertUserInfo({
              'userID': user.userID,
              'name': user.name,
              'email': user.email,
              'accountType': user.accountType,
              'points': user.points,
              'level': user.level
            });

            // Update state with fresh data
            setState(() {
              _userInfo = {
                'userID': user.userID,
                'name': user.name,
                'email': user.email,
                'accountType': user.accountType,
                'points': user.points,
                'level': user.level
              };
            });
          }
        } catch (apiError) {
          print("❌ API error in _loadUserProfile: $apiError");
          // Don't throw here - we already have local data displayed
        }
      }
    } catch (e) {
      print("❌ Error in _loadUserProfile: $e");
      // If both local and API fail, show error state
      setState(() {
        _userInfo = {'accountType': 'basic', 'name': 'Unknown'};
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
    // Khi tab hiện tại được focus
    if (ModalRoute.of(context)?.isCurrent == true) {
      refreshUser();
    }
  }

  void refreshUser() {
    _loadUserProfile(dbHelper);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // BẮT BUỘC khi dùng keepAlive
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
                          text: 'Welcome Back, ',
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
              // Trong onTap của container
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
                        // Xử lý nếu cần dùng selectedType, không cần điều hướng nữa
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
