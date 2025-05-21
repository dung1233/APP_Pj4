// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/screens/User/status.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/offline/WorkoutSyncService.dart';

import '../../APi/user_service.dart';
import '../../data/local_storage.dart';
import 'PurchasedItemsPage.dart';
import '../Home/home.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserProfilePage>
    with AutomaticKeepAliveClientMixin<UserProfilePage> {
  final dbHelper = DatabaseHelper();
  // Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _userInfo = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _printDatabaseContent(dbHelper);
    _loadUserProfile(dbHelper);
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

  Future<void> _printDatabaseContent(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;
    final userInfo = await db.query('user_info');
    print("❓ Dữ liệu bảng user_info:");
    userInfo.forEach((user) => print(user));
    // final userProfiles = await db.query('user_profile');
    // print("❓ Dữ liệu bảng user_profile:");
    // userProfiles.forEach((profile) => print(profile));
  }

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

  Future<void> navigateToStatusScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatusScreen()),
    );
    if (result == true) {
      setState(() {});
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

  // Navigate to Purchased Items Page
  Future<void> navigateToPurchasedItemsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PurchasedItemsPage()),
    );
  }

  Future<void> _logout() async {
    try {
      // Xóa dữ liệu từ WorkoutSyncService
      final syncService = WorkoutSyncService();
      await syncService.clearAllData();

      // Xóa dữ liệu từ DatabaseHelper
      await dbHelper.clearAllDataOnLogout();

      // Xóa token và các dữ liệu khác từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // BẮT BUỘC khi dùng keepAlive
    final accountTypeRaw = _userInfo['accountType'] ?? 'basic';
    final accountType = capitalize(accountTypeRaw);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tài khoản",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
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
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/img/avatar.jpg"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userInfo['name'] ?? 'Tên người dùng',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Thông số cá nhân"),
                    onTap: navigateToStatusScreen,
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Cài đặt & Bảo mật"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text("Ngôn ngữ"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text("Sản Phẩm Đã Mua"),
                    onTap: navigateToPurchasedItemsPage,
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text("Chế độ tối"),
                    trailing: Switch(value: false, onChanged: (val) {}),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Đăng xuất",
                        style: TextStyle(color: Colors.red)),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
