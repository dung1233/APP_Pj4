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
  List<List<Workout>> weeks = []; // ✅ Dữ liệu từ Hive
  bool isLoading = true; // ✅ Trạng thái tải dữ liệu
  Map<int, bool> expandedDays = {};
  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromSQLite(); // ✅ Tải dữ liệu từ Hive khi widget khởi tạo
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                    child: Column(
                                      children: [
                                        // Header với thông tin tổng quan
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: completedCount ==
                                                    dayWorkouts.length
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                            child: Text(
                                              "$day",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: completedCount ==
                                                        dayWorkouts.length
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "Ngày $day",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "$completedCount/${dayWorkouts.length} bài hoàn thành",
                                            style: TextStyle(
                                              color: completedCount ==
                                                      dayWorkouts.length
                                                  ? Colors.green
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                          trailing: Icon(
                                            isExpanded
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: Colors.grey,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              expandedDays[day] = !isExpanded;
                                            });
                                          },
                                        ),

                                        // Phần mở rộng với danh sách bài tập
                                        if (isExpanded)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Column(
                                              children: dayWorkouts
                                                  .map((workout) =>
                                                      _buildWorkoutItem(
                                                          workout))
                                                  .toList(),
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

  Widget _buildWorkoutItem(Workout workout) {
    final isRestDay =
        workout.exerciseName?.toLowerCase().contains("nghỉ ngơi") ?? false;
    final displayStatus = isRestDay ? "NOT_STARTED" : workout.status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              "assets/img/OP5.jpg",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            workout.exerciseName ?? "Không tên",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              // Hiển thị thông tin phù hợp với loại bài tập
              if (workout.sets! > 0 && workout.reps! > 0)
                Text(
                  "${workout.sets} hiệp × ${workout.reps} lần",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              if (workout.duration! > 0)
                Text(
                  "${workout.duration} phút${workout.distance! > 0 ? ' - ${workout.distance}km' : ''}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              const SizedBox(height: 4),
              // Trạng thái
              Text(
                _getStatusText(workout.status),
                style: TextStyle(
                  color: _getStatusColor(workout.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              displayStatus == "COMPLETED"
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: displayStatus == "COMPLETED"
                  ? const Color.fromARGB(255, 14, 228, 50)
                  : Colors.grey,
              size: 28,
            ),
            onPressed: isRestDay ? null : () => _toggleWorkoutStatus(workout),
          ),
        ),
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
