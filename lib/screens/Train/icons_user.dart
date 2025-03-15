import 'package:flutter/material.dart';

class IconsUser extends StatefulWidget {
  final Map<String, dynamic> userData;
  const IconsUser({super.key, required this.userData});

  @override
  // ignore: library_private_types_in_public_api
  _IconsUserState createState() => _IconsUserState();
}

class _IconsUserState extends State<IconsUser> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 10, left: 22, right: 20), // Đẩy xuống một chút cho đẹp
      child: Container(
        width: double.infinity, // Căng hết chiều ngang
        height: 50,
        padding: const EdgeInsets.symmetric(
            horizontal: 10), // Thêm padding để cân đối
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều 2 bên
          children: [
            Row(
              children: [
                Text(
                  'Welcome Back, ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  widget.userData['name'] ?? 'Chưa có dữ liệu',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            Icon(Icons.account_circle,
                size: 30, color: Colors.black), // Icon người dùng
          ],
        ),
      ),
    );
  }
}
