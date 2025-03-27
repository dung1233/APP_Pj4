// TODO Implement this library.
import 'package:app/work.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final List<Map<String, dynamic>> workouts = [
    {
      "animation": "assets/img/Animation - 1742982248147.json",
      "name": "Push-Up",
      "sets": 4,
      "reps": 10,
    },
    {
      "animation": "assets/img/Animation - 1743004318512.json",
      "name": "Runner",
      "sets": 3,
      "reps": 12,
    },
    {
      "animation": "assets/img/Animation - 1743005455297.json",
      "name": "Sit-Up",
      "sets": 3,
      "reps": 20,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 1,
      ),
      body: ListView(
        children: [
          Container(
            height: 250,
            padding: const EdgeInsets.only(left: 25, top: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, offset: Offset(0, 2), blurRadius: 5),
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
                const SizedBox(height: 20),
                Text(
                  "Day 1",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Text(
                //   "Squat & Push-up",
                //   style: TextStyle(
                //       fontSize: 20,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.yellowAccent),
                // ),
                const SizedBox(height: 5),
                Text(
                  "Khởi động sức mạnh",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "18 phut - 10 bai tap",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                  left: 15,
                ),
                child: Text(
                  "18 phút  - 10 Lần tập",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text("Danh sách bài tập"),
              SizedBox(
                height: 500, // 🔥 Đặt chiều cao cố định cho ListView
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    return WorkoutItem(
                      animationPath: workouts[index]["animation"],
                      exerciseName: workouts[index]["name"],
                      sets: workouts[index]["sets"],
                      reps: workouts[index]["reps"],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
