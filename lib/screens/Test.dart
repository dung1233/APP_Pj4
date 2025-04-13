// TODO Implement this library.
import 'package:training_souls/screens/TEST/pushup_detector_view.dart';
import 'package:training_souls/work.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getheightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  final List<Map<String, dynamic>> workouts = [
    {
      "animation": "assets/img/Animation - 1743427831861.json",
      "name": "Squat",
      "sets": 4,
      "reps": 10,
    },
    {
      "animation": "assets/img/Animation - 1742982248147.json",
      "name": "Push-Up",
      "sets": 4,
      "reps": 10,
    },
    {
      "animation": "assets/img/Animation - 1743004318512.json",
      "name": "Sit-Up",
      "sets": 3,
      "reps": 12,
    },
    {
      "animation": "assets/img/Animation - 1743005455297.json",
      "name": "Runner",
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
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Container(
              height: getheightPercentage(context, 0.23),
              padding: const EdgeInsets.only(left: 25, top: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 5),
                ],
                image: DecorationImage(
                  image: AssetImage("assets/img/situp.jpg"), // 🔥 Hiển thị ảnh
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
                    "Day 3",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    " Sức mạnh",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "18 phut - 10 bai tap",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 15),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround, // Chia đều khoảng cách
                    children: [
                      _buildMetricItem("300", "Calo"),
                      _buildMetricItem("3", "Set"),
                      _buildMetricItem("18p", "Thời gian"),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Danh sách bài tập",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: getheightPercentage(
                      context, 0.54), // 🔥 Đặt chiều cao cố định cho ListView
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PushUpDetectorView()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6F00), // Màu nút
                    padding:
                        EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Start",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMetricItem(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
      SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}
