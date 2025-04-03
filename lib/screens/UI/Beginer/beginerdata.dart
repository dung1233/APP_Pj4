import 'package:app/data/DatabaseHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/models/work_out.dart';

class BeginnerDataWidget extends StatefulWidget {
  const BeginnerDataWidget({super.key});

  @override
  State<BeginnerDataWidget> createState() => _BeginnerDataWidgetState();
}

class _BeginnerDataWidgetState extends State<BeginnerDataWidget> {
  List<List<Workout>> weeks = []; // ✅ Dữ liệu từ Hive
  bool isLoading = true; // ✅ Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromSQLite(); // ✅ Tải dữ liệu từ Hive khi widget khởi tạo
  }

  /// ✅ Hàm này lấy dữ liệu từ Hive và nhóm theo tuần
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
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // ⏳ Hiển thị loading nếu chưa có dữ liệu
          : Column(
              children: weeks.asMap().entries.map((entry) {
                int weekIndex = entry.key;
                List<Workout> weekData = entry.value;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Tiêu đề tuần
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFFF6F00),
                                  Color(0xFFFF6F00)
                                ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Week ${weekIndex + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text('0/6 Days',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ✅ Danh sách bài tập
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: weekData.length,
                        itemBuilder: (context, index) {
                          final workout = weekData[index];
                          return Stack(
                            children: [
                              if (index < weekData.length - 1)
                                Positioned(
                                  left: 30,
                                  top: 50,
                                  bottom: -10,
                                  child: Container(
                                    width: 3,
                                    color: Color(0xFFFF6F00).withOpacity(0.8),
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Container(
                                  width: 300,
                                  height: 155,
                                  padding:
                                      const EdgeInsets.only(left: 20, top: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 4),
                                          blurRadius: 8),
                                    ],
                                    image: DecorationImage(
                                      image: AssetImage("assets/img/OP5.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Day ${workout.day ?? 'Unknown'}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        workout.exerciseName ?? "No Name",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Sets: ${workout.sets ?? 0} - Reps: ${workout.reps ?? 0}",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  workout.status == "COMPLETED"
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              workout.status == "COMPLETED"
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color:
                                                  workout.status == "COMPLETED"
                                                      ? Colors.green
                                                      : Colors.grey,
                                            ),
                                            onPressed: () async {
                                              final dbHelper = DatabaseHelper();
                                              String newStatus =
                                                  workout.status == "COMPLETED"
                                                      ? "NOT_STARTED"
                                                      : "COMPLETED";

                                              await dbHelper
                                                  .updateWorkoutStatus(
                                                      workout.id!, newStatus);

                                              setState(() {
                                                workout.status = newStatus;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
