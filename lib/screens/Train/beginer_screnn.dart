import 'package:app/screens/Test.dart';
import 'package:app/screens/UI/Beginer/trainbeginer.dart';
import 'package:flutter/material.dart';

class BeginnerScreen extends StatelessWidget {
  const BeginnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 250,
      padding: const EdgeInsets.only(left: 25, top: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 5),
        ],
        image: DecorationImage(
          image: AssetImage("assets/img/pushup.jpg"), // 🔥 Hiển thị ảnh
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // ignore: deprecated_member_use
            Colors.black.withOpacity(0.5), // 🔥 Làm tối ảnh nền
            BlendMode.darken,
          ), // 🔥 Ảnh sẽ căng full khung
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Day: 1",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Squat & Push-up",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.yellowAccent),
          ),
          const SizedBox(height: 5),
          Text(
            "Khởi động sức mạnh",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext) => AIMyWidget()));
            },
            child: Text(
              "Start",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
