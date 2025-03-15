// ignore: file_names
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required Map<String, dynamic> userData});

  @override
  // ignore: library_private_types_in_public_api
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
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

            // Ảnh đại diện + Tên
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        "assets/img/avatar.jpg"), // Hoặc dùng NetworkImage()
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nguyễn Văn A",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Danh sách tùy chọn
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Tài khoản"),
                    onTap: () {},
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
                    title: const Text("Đăng xuất",
                        style: TextStyle(color: Colors.red)),
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
