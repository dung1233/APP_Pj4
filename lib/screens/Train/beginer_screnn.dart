import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/Test.dart';
import 'package:training_souls/screens/UI/Beginer/trainbeginer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BeginerScrenn extends StatefulWidget {
  const BeginerScrenn({Key? key}) : super(key: key);

  @override
  _BeginerScrennState createState() => _BeginerScrennState();
}

class _BeginerScrennState extends State<BeginerScrenn> {
  List<List<Workout>> weeks = []; // ✅ Dữ liệu từ Hive
  bool isLoading = true; // ✅ Trạng thái tải dữ liệu
  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromSQLite(); // ✅ Tải dữ liệu từ Hive khi widget khởi tạo
  }

  Future<void> _loadWorkoutsFromSQLite() async {
    final dbHelper =
        DatabaseHelper(); // 🛠 Sử dụng DatabaseHelper để truy cập SQLite
    final List<Workout> allWorkouts =
        await dbHelper.getWorkouts(); // 📦 Lấy dữ liệu từ SQLite

    if (allWorkouts.isEmpty) {
      if (kDebugMode) {
        print("⚠️ Không có dữ liệu trong SQLite.");
      }
      setState(() => isLoading = false);
      return;
    }

    // ✅ Chia bài tập thành danh sách tuần
    List<List<Workout>> groupedWeeks = [];
    for (var i = 0; i < allWorkouts.length; i += 7) {
      groupedWeeks.add(allWorkouts.sublist(
          i, (i + 7) > allWorkouts.length ? allWorkouts.length : (i + 7)));
    }

    setState(() {
      weeks = groupedWeeks; // 🛠 Cập nhật UI với dữ liệu từ SQLite
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 200,
      padding: const EdgeInsets.only(left: 25, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // 🔥 Tăng độ bo góc
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8),
        ],
        image: DecorationImage(
          image: AssetImage("assets/img/situp.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color.fromARGB(255, 0, 0, 0)
                .withOpacity(0.5), // 🔥 Overlay màu cam nhẹ
            BlendMode.multiply,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Day 3",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Squat & Sit-up",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Khởi động sức mạnh",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Spacer(),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              side: BorderSide(color: Colors.white, width: 1), // Viền trắng
              backgroundColor: Color.fromARGB(255, 255, 255, 255), // 🔥 Nền cam
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)), // 🔥 Bo góc
            ),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Test()));
            },
            child: Text(
              "Start",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
