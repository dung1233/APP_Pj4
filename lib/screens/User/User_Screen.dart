// ignore: file_names
import 'package:flutter/material.dart';
import 'package:training_souls/screens/User/status.dart';

import '../../data/DatabaseHelper.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserProfilePage> with AutomaticKeepAliveClientMixin<UserProfilePage>{

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
    final db = await dbHelper.database;
    final name = await db.query('user_info');
    // final profiles = await db.query('user_profile');
    if (name.isNotEmpty) {
      setState(() {
        // _userProfile = profiles.first;
        _userInfo = name.first;
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    leading: const Icon(Icons.dark_mode),
                    title: const Text("Chế độ tối"),
                    trailing: Switch(value: false, onChanged: (val) {}),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                    onTap: () {},
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
