import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/api/user_service.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/data/local_storage.dart';

class IconsUser extends StatefulWidget {
  const IconsUser({super.key});

  @override
  _IconsUserState createState() => _IconsUserState();
}

class _IconsUserState extends State<IconsUser> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 22, right: 20),
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : Row(
                    children: [
                      const Text(
                        'Welcome Back, ',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Text(
                        userName ?? 'aa',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
            const Icon(Icons.account_circle, size: 30, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
