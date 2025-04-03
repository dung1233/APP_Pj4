import 'package:app/screens/User/status.dart';
import 'package:flutter/material.dart';


class IconsUser extends StatefulWidget {
  const IconsUser({super.key});

  @override
  _IconsUserState createState() => _IconsUserState();
}

class _IconsUserState extends State<IconsUser> {
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
            Row(
              children: [
                const Text(
                  'Welcome Back, ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const Text(
                  'name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatusScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
