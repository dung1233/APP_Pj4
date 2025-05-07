import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/start/Test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BeginerScrenn extends StatefulWidget {
  const BeginerScrenn({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BeginnerScreenState createState() => _BeginnerScreenState();
}

class _BeginnerScreenState extends State<BeginerScrenn> {
  List<List<Workout>> weeks = [];
  bool isLoading = true;
  Workout? nextWorkout; // Bài tập tiếp theo cần thực hiện
  bool showCompletionMessage = false; // Bài tập tiếp theo cần thực hiện
  bool allWorkoutsCompleted =
      false; // Flag để biết khi tất cả bài tập đã hoàn thành

  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromSQLite();
  }

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

    // ✅ Sắp xếp theo ngày
    allWorkouts.sort((a, b) => (a.day ?? 0).compareTo(b.day ?? 0));

    // ✅ Debug: in danh sách tất cả bài tập
    for (var w in allWorkouts) {
      print("📆 Ngày ${w.day}, ${w.exerciseName}, trạng thái: ${w.status}");
    }

    // Lấy ngày hiện tại để biết hôm nay là ngày bao nhiêu trong chương trình
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Tìm bài tập cuối cùng đã hoàn thành
    final completedWorkouts =
        allWorkouts.where((w) => w.status == "COMPLETED").toList();

    Workout? workoutToShow;

    if (completedWorkouts.isEmpty) {
      // Chưa có bài tập nào được hoàn thành, hiển thị bài đầu tiên
      workoutToShow = allWorkouts.firstWhere((w) => w.status == "NOT_COMPLETED",
          orElse: () => allWorkouts.first);
      print(
          "👉 Bắt đầu chương trình: ngày ${workoutToShow.day}, ${workoutToShow.exerciseName}");
    } else {
      // Sắp xếp các bài tập đã hoàn thành theo ngày
      completedWorkouts.sort((a, b) => (a.day ?? 0).compareTo(b.day ?? 0));

      // Lấy bài tập cuối cùng đã hoàn thành
      final lastCompletedWorkout = completedWorkouts.last;
      final int lastCompletedDay = lastCompletedWorkout.day ?? 0;

      // Kiểm tra xem bài tập cuối cùng được hoàn thành vào ngày hôm nay không
      final DateTime? completionDate =
          lastCompletedWorkout.completionDate != null
              ? DateTime.parse(lastCompletedWorkout.completionDate!)
              : null;

      final bool completedToday = completionDate != null &&
          completionDate.year == today.year &&
          completionDate.month == today.month &&
          completionDate.day == today.day;

      if (completedToday) {
        // Nếu đã hoàn thành một bài tập hôm nay, hiển thị thông báo
        setState(() {
          isLoading = false;
          nextWorkout =
              lastCompletedWorkout; // Để UI có thể hiển thị thông tin bài tập đã hoàn thành
          showCompletionMessage = true;
        });
        print(
            "👉 Đã hoàn thành bài ngày $lastCompletedDay hôm nay. Cần đợi đến ngày mai.");
        return;
      }

      // Tìm bài tập tiếp theo chưa hoàn thành
      try {
        workoutToShow = allWorkouts.firstWhere(
          (w) => (w.day ?? 0) > lastCompletedDay && w.status == "NOT_COMPLETED",
        );
        print(
            "👉 Bài tập tiếp theo: ngày ${workoutToShow.day}, ${workoutToShow.exerciseName}");
      } catch (e) {
        // Không tìm thấy bài tập nào chưa hoàn thành
        print("👉 Đã hoàn thành tất cả bài tập trong chương trình.");

        // Hiển thị bài tập cuối cùng đã hoàn thành thay vì quay lại bài đầu tiên
        workoutToShow = lastCompletedWorkout;
        setState(() {
          allWorkoutsCompleted = true;
        });
      }
    }

    setState(() {
      nextWorkout = workoutToShow;
      isLoading = false;
      showCompletionMessage = false; // Reset thông báo hoàn thành
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nextWorkout == null) {
      return const Center(child: Text("Không có bài tập nào"));
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 250,
      padding: const EdgeInsets.only(left: 25, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8),
        ],
        image: DecorationImage(
          image: AssetImage("assets/img/run.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.multiply,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              allWorkoutsCompleted
                  ? "Bài tập đã hoàn thành!"
                  : "Ngày ${nextWorkout!.day ?? '1'}",
              style: GoogleFonts.urbanist(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),

          if (showCompletionMessage) ...[
            // Thông báo đã hoàn thành bài tập hôm nay
            const SizedBox(height: 8),
            Text(
              "Đã hoàn thành bài tập hôm nay",
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ] else if (allWorkoutsCompleted) ...[
            // Thông báo đã hoàn thành toàn bộ chương trình
            const SizedBox(height: 8),
            Text(
              "Bạn đã hoàn thành bài tập ngày ${nextWorkout!.day ?? '1'}",
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 5),
          ] else ...[
            // Hiển thị thông tin bài tập bình thường
            const SizedBox(height: 8),
            Text(
              nextWorkout!.exerciseName ?? "Bài tập không tên",
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _getWorkoutDescription(nextWorkout!),
              style: GoogleFonts.urbanist(fontSize: 18, color: Colors.white),
            ),
          ],

          const SizedBox(height: 20),

          // Hiển thị nút "Bắt đầu" chỉ khi chưa hoàn thành bài tập hôm nay
          // và chưa hoàn thành toàn bộ chương trình
          if (!showCompletionMessage && !allWorkoutsCompleted)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                side: const BorderSide(color: Colors.white, width: 1),
                backgroundColor: Color(0xFFFF6F00),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Test()));
              },
              child: Text(
                "Bắt đầu",
                style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),

          const Spacer(),
        ],
      ),
    );
  }

  String _getWorkoutDescription(Workout workout) {
    if (workout.sets != null &&
        workout.sets! > 0 &&
        workout.reps != null &&
        workout.reps! > 0) {
      return "${workout.sets} hiệp × ${workout.reps} lần";
    } else if (workout.duration != null && workout.duration! > 0) {
      return "${workout.duration} phút${workout.distance != null && workout.distance! > 0 ? ' - ${workout.distance}km' : ''}";
    }
    return "Khởi động sức mạnh"; // Mặc định
  }
}
