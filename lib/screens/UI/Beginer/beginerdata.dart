import 'dart:math';

import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/models/work_out.dart';

class BeginnerDataWidget extends StatefulWidget {
  const BeginnerDataWidget({super.key});

  @override
  State<BeginnerDataWidget> createState() => _BeginnerDataWidgetState();
}

class _BeginnerDataWidgetState extends State<BeginnerDataWidget> {
  List<List<Workout>> weeks = []; // ✅ Dữ liệu từ SQLite
  bool isLoading = true; // ✅ Trạng thái tải dữ liệu
  Map<int, bool> expandedDays = {};
  final List<String> workoutBackgrounds = [
    "assets/img/run.jpg",
    "assets/img/gapbung.jpg",
    "assets/img/pushup.jpg",
    "assets/img/squat.jpg",
    "assets/img/OP5.jpg",
    // Thêm các đường dẫn ảnh khác
  ];
  String getRandomImageForDay(int day) {
    // Sử dụng số ngày làm seed để ảnh cho mỗi ngày luôn cố định
    final random = Random(day);
    return workoutBackgrounds[random.nextInt(workoutBackgrounds.length)];
  }

  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromSQLite();
    // ✅ Tải dữ liệu từ Hive khi widget khởi tạo
  }

  Future<bool> checkExerciseCompletion(int day, String exerciseName) async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getExerciseResults(day);

    // Kiểm tra xem bài tập có trong kết quả không
    for (var result in results) {
      if (result['exercise_name'] == exerciseName) {
        // Thay đổi từ exerciseName thành exercise_name
        return true; // Đã hoàn thành
      }
    }

    return false; // Chưa hoàn thành
  }

  Future<void> _updateCompletionStatus() async {
    final dbHelper = DatabaseHelper();

    bool anyChange = false; // 🆕 Thêm flag xem có gì thay đổi không

    for (var weekWorkouts in weeks) {
      for (var workout in weekWorkouts) {
        if (workout.day != null && workout.exerciseName != null) {
          bool isCompleted = await checkExerciseCompletion(
              workout.day!, workout.exerciseName!);

          if (isCompleted && workout.status != "COMPLETED") {
            await dbHelper.updateWorkoutStatus(workout.id!, "COMPLETED");
            workout.status = "COMPLETED";
            anyChange = true; // Có thay đổi
          }
        }
      }
    }

    if (mounted && anyChange)
      setState(() {}); // 🆕 Chỉ setState nếu có thay đổi
  }

  Future<void> saveExerciseResult(int day, String exerciseName) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertExerciseResult(day, exerciseName);

    // Sau khi lưu xong, cập nhật trạng thái bài tập
    await _updateCompletionStatus();

    // Nếu muốn chắc chắn hơn nữa (nếu dữ liệu bài tập thay đổi nhiều), thay bằng:
    // await _loadWorkoutsFromSQLite();
  }

  /// ✅ Hàm này lấy dữ liệu từ Hive và nhóm theo tuần
  Future<void> _loadWorkoutsFromSQLite() async {
    final dbHelper = DatabaseHelper();
    final List<Workout> allWorkouts = await dbHelper.getWorkouts();

    if (allWorkouts.isEmpty) {
      if (kDebugMode) {
        print("⚠️ Không có dữ liệu trong SQLite.");
      }
      setState(() => isLoading = false);
      return;
    }

    // Nhóm bài tập theo ngày
    Map<int, List<Workout>> workoutsByDay = {};
    for (var workout in allWorkouts) {
      if (workout.day != null) {
        workoutsByDay.putIfAbsent(workout.day!, () => []).add(workout);
      }
    }

    // Chuyển thành danh sách tuần (mỗi tuần 7 ngày)
    List<List<Workout>> groupedWeeks = [];
    List<Workout> currentWeek = [];

    // Sắp xếp các ngày theo thứ tự
    var sortedDays = workoutsByDay.keys.toList()..sort();

    for (int day in sortedDays) {
      currentWeek.addAll(workoutsByDay[day]!);

      // Nếu đủ 7 ngày hoặc hết danh sách thì tạo tuần mới
      if (day % 7 == 0 || day == sortedDays.last) {
        groupedWeeks.add(currentWeek);
        currentWeek = [];
      }
    }

    setState(() {
      weeks = groupedWeeks;
      isLoading = false;
    });
    _updateCompletionStatus();
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
                final weekData = entry.value;
                final Map<int, List<Workout>> workoutsByDay = {};
                for (var workout in weekData) {
                  if (workout.day != null) {
                    workoutsByDay
                        .putIfAbsent(workout.day!, () => [])
                        .add(workout);
                  }
                }
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
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('0/6 Days',
                                style: GoogleFonts.urbanist(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      workoutsByDay.isEmpty
                          ? Center(
                              child: Text("Không có bài tập trong tuần này"))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: workoutsByDay.keys.length,
                              itemBuilder: (context, index) {
                                final day = workoutsByDay.keys.elementAt(index);
                                final dayWorkouts = workoutsByDay[day] ?? [];
                                final completedCount = dayWorkouts
                                    .where((w) => w.status == "COMPLETED")
                                    .length;
                                final isExpanded = expandedDays[day] ?? false;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Column(
                                    children: [
                                      // Container đẹp thay thế cho Card
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            expandedDays[day] = !isExpanded;
                                          });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.93,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  offset: Offset(0, 5),
                                                  blurRadius: 10),
                                            ],
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  getRandomImageForDay(day)),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.6),
                                                BlendMode.multiply,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Ngày $day",
                                                    style: GoogleFonts.urbanist(
                                                        fontSize: 26,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange
                                                          .withOpacity(0.8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      "$completedCount/${dayWorkouts.length} bài hoàn thành",
                                                      style:
                                                          GoogleFonts.urbanist(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              CircleAvatar(
                                                backgroundColor: Colors.black45,
                                                radius: 18,
                                                child: Icon(
                                                  isExpanded
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Phần mở rộng với danh sách bài tập
                                      if (isExpanded)
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          margin: const EdgeInsets.only(top: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: dayWorkouts
                                                .map((workout) =>
                                                    _buildWorkoutItem(workout))
                                                .toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            )
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildWorkoutItem(Workout workout) {
    final isRestDay =
        workout.exerciseName?.toLowerCase().contains("nghỉ ngơi") ?? false;
    final displayStatus = isRestDay ? "NOT_STARTED" : workout.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Hình ảnh bài tập
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/img/OP5.jpg",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),

          // Thông tin bài tập
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.exerciseName ?? "Không tên",
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                // Hiển thị thông tin phù hợp với loại bài tập
                if (workout.sets! > 0 && workout.reps! > 0)
                  Text(
                    "${workout.sets} hiệp × ${workout.reps} lần",
                    style: GoogleFonts.urbanist(color: Colors.grey[600]),
                  ),
                if (workout.duration! > 0)
                  Text(
                    "${workout.duration} phút${workout.distance! > 0 ? ' - ${workout.distance}km' : ''}",
                    style: GoogleFonts.urbanist(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 4),
                // Trạng thái
                Text(
                  _getStatusText(workout.status),
                  style: GoogleFonts.urbanist(
                    color: _getStatusColor(workout.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Nút check hoàn thành
          InkWell(
            onTap: isRestDay ? null : () => _toggleWorkoutStatus(workout),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: displayStatus == "COMPLETED"
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
              ),
              child: Icon(
                displayStatus == "COMPLETED"
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: displayStatus == "COMPLETED"
                    ? const Color.fromARGB(255, 14, 228, 50)
                    : Colors.grey,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case "COMPLETED":
        return "Đã hoàn thành";
      case "MISSED":
        return "Đã bỏ lỡ";
      case "NOT_STARTED":
        return "Chưa bắt đầu";
      default:
        return "Chưa bắt đầu";
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "COMPLETED":
        return Colors.green;
      case "MISSED":
        return Colors.orange;
      case "NOT_STARTED":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _toggleWorkoutStatus(Workout workout) async {
    final dbHelper = DatabaseHelper();
    final newStatus =
        workout.status == "COMPLETED" ? "NOT_STARTED" : "COMPLETED";

    await dbHelper.updateWorkoutStatus(workout.id!, newStatus);

    setState(() {
      workout.status = newStatus;
    });
  }
}
