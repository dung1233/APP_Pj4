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
  DateTime? programStartDate;
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

    // Xác định ngày hiện tại
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Ngày bắt đầu chương trình dựa vào workoutDate
    programStartDate ??= allWorkouts
        .map((e) => e.workoutDate)
        .whereType<String>()
        .map((s) => DateTime.tryParse(s))
        .whereType<DateTime>()
        .reduce((a, b) => a.isBefore(b) ? a : b);

    if (programStartDate == null) {
      if (kDebugMode) print("⚠️ Không có ngày bắt đầu chương trình");
      setState(() => isLoading = false);
      return;
    }

    final int currentProgramDay =
        today.difference(programStartDate!).inDays + 1;
    if (kDebugMode) {
      print("📅 Ngày hiện tại trong chương trình: $currentProgramDay");
    }

    // Tìm workout của ngày hiện tại
    final todayWorkout = allWorkouts.firstWhere(
      (w) => w.day == currentProgramDay,
      orElse: () => Workout(),
    );

    if (todayWorkout.exerciseName == null) {
      // fallback nếu không tìm thấy bài hôm nay
      setState(() {
        isLoading = false;
        nextWorkout = allWorkouts.firstWhere(
          (w) => w.status == "NOT_COMPLETED",
          orElse: () => allWorkouts.first,
        );
      });
      return;
    }

    // Kiểm tra bài hôm nay đã hoàn thành chưa
    bool isCompletedToday = false;
    if (todayWorkout.status == "COMPLETED" &&
        todayWorkout.completionDate != null) {
      final completionDate = DateTime.parse(todayWorkout.completionDate!);
      if (completionDate.year == today.year &&
          completionDate.month == today.month &&
          completionDate.day == today.day) {
        isCompletedToday = true;
      }
    }

    setState(() {
      nextWorkout = todayWorkout;
      showCompletionMessage = isCompletedToday;
      isLoading = false;
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
              "✅ Bạn đã hoàn thành bài tập hôm nay",
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ] else if (allWorkoutsCompleted) ...[
            // Thông báo đã hoàn thành toàn bộ chương trình
            const SizedBox(height: 8),
            Text(
              "Chúc mừng! Bạn đã hoàn thành toàn bộ chương trình tập luyện!",
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],

          // Hiển thị nút "Bắt đầu" chỉ khi chưa hoàn thành bài tập hôm nay
          // và chưa hoàn thành toàn bộ chương trình
          if (!allWorkoutsCompleted && !showCompletionMessage) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                side: const BorderSide(color: Colors.white, width: 1),
                backgroundColor: const Color(0xFFFF6F00),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Test()),
                );
              },
              child: Text(
                "Bắt đầu",
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

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
