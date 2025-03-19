import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
    _loadWorkoutsFromHive(); // ✅ Tải dữ liệu từ Hive khi widget khởi tạo
  }

  /// ✅ Hàm này lấy dữ liệu từ Hive và nhóm theo tuần
  Future<void> _loadWorkoutsFromHive() async {
    final box = Hive.box<Workout>('workouts'); // 📦 Lấy dữ liệu từ Hive
    final List<Workout> allWorkouts = box.values.toList();

    if (allWorkouts.isEmpty) {
      print("⚠️ Không có dữ liệu trong Hive.");
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
      weeks = groupedWeeks; // 🛠 Cập nhật UI với dữ liệu từ Hive
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Tiêu đề tuần
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Colors.green, Colors.teal]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Week ${weekIndex + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 12),
                              child: Row(
                                children: [
                                  // ✅ Icon bên trái
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(Icons.fitness_center,
                                        color: Colors.deepPurple, size: 30),
                                  ),
                                  const SizedBox(width: 15),

                                  // ✅ Nội dung bài tập
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Day ${workout.day ?? 'Unknown'}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          workout.exerciseName ?? "No Name",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple),
                                        ),
                                        Text(
                                          "Sets: ${workout.sets ?? 0} - Reps: ${workout.reps ?? 0}",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
