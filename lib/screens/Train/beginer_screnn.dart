import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/Train/rest.dart';
import 'package:training_souls/screens/UI/Beginer/situp.dart';
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

    // ✅ Lọc bài đầu tiên chưa bắt đầu
    final notStartedWorkout = allWorkouts.firstWhere(
      (workout) => workout.status == "NOT_COMPLETED",
      orElse: () => allWorkouts.first,
    );

    print(
        "👉 Chọn bài: ngày ${notStartedWorkout.day}, ${notStartedWorkout.exerciseName}");

    setState(() {
      nextWorkout = notStartedWorkout;
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
          const SizedBox(height: 25),
          Text(
            "Ngày ${nextWorkout!.day ?? '1'}",
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            nextWorkout!.exerciseName ?? "Bài tập không tên",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _getWorkoutDescription(nextWorkout!),
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const Spacer(),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              side: const BorderSide(color: Colors.white, width: 1),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Test()));
            },
            child: const Text(
              "Bắt đầu",
              style: TextStyle(
                  color: Colors.black,
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
    if (workout.sets! > 0 && workout.reps! > 0) {
      return "${workout.sets} hiệp × ${workout.reps} lần";
    } else if (workout.duration! > 0) {
      return "${workout.duration} phút${workout.distance! > 0 ? ' - ${workout.distance}km' : ''}";
    }
    return "Khởi động sức mạnh"; // Mặc định
  }
}
