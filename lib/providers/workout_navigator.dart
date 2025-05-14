// import 'package:flutter/material.dart';
// import 'package:training_souls/data/DatabaseHelper.dart';
// import 'package:training_souls/models/work_out.dart';
// import 'package:training_souls/screens/TEST/pushup_detector_view.dart';
// import 'package:training_souls/screens/TEST/squat_detector_view.dart';
// import 'package:training_souls/screens/Train/rest.dart';
// import 'package:training_souls/screens/UI/Beginer/situp.dart';
// import 'package:training_souls/screens/UI/Beginer/run.dart';
// import 'package:camera/camera.dart';

// class WorkoutNavigator {
//   final BuildContext context;
//   final DatabaseHelper dbHelper;
//   static List<CameraDescription>? cameras;
//   static bool _camerasInitialized = false;

//   WorkoutNavigator(this.context) : dbHelper = DatabaseHelper();

//   // Khởi tạo camera một lần duy nhất
//   static Future<void> initializeCameras() async {
//     if (!_camerasInitialized && cameras == null) {
//       try {
//         cameras = await availableCameras();
//         _camerasInitialized = true;
//       } catch (e) {
//         print('Lỗi khởi tạo camera: $e');
//         throw e;
//       }
//     }
//   }

//   Future<void> navigateToTraining(int day) async {
//     // Show loading dialog
//     _showLoadingDialog();

//     try {
//       // Khởi tạo camera trước khi điều hướng
//       await initializeCameras();

//       // Lấy danh sách bài tập của ngày
//       final dayWorkouts =
//           (await dbHelper.getWorkouts()).where((w) => w.day == day).toList();

//       // Dismiss loading dialog
//       Navigator.pop(context);

//       // Nếu không có bài tập nào, trả về
//       if (dayWorkouts.isEmpty) {
//         print("⚠️ Không có bài tập nào cho ngày $day");
//         _showMessage("Không có bài tập nào cho ngày $day");
//         return;
//       }

//       // Sắp xếp bài tập theo trạng thái chưa hoàn thành
//       dayWorkouts.sort((a, b) {
//         if (a.status == "COMPLETED" && b.status != "COMPLETED") return 1;
//         if (a.status != "COMPLETED" && b.status == "COMPLETED") return -1;
//         return 0;
//       });

//       // Tìm bài tập đầu tiên chưa hoàn thành
//       Workout? nextWorkout = dayWorkouts.firstWhere(
//         (w) => w.status != "COMPLETED",
//         orElse: () => dayWorkouts.first,
//       );

//       if (nextWorkout.status == "COMPLETED") {
//         _showMessage("Tất cả bài tập ngày $day đã hoàn thành!");
//         return;
//       }

//       // Ánh xạ tên bài tập với màn hình tương ứng
//       final exerciseName = nextWorkout.exerciseName?.toLowerCase() ?? "";

//       // Xác định loại bài tập và điều hướng
//       if (exerciseName.contains("chạy bộ")) {
//         _navigateToRunning(day);
//       } else if (exerciseName.contains("hít đất")) {
//         await _navigateToPushUp(day);
//       } else if (exerciseName.contains("squat")) {
//         await _navigateToSquat(day);
//       } else if (exerciseName.contains("gập bụng")) {
//         await _navigateToSitUp(day);
//       } else {
//         print(
//             "⚠️ Không tìm thấy màn hình phù hợp cho bài tập: ${nextWorkout.exerciseName}");
//         _showMessage("Không tìm thấy bài tập phù hợp");
//       }
//     } catch (e) {
//       // Dismiss loading dialog if still showing
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
//       _showMessage("Lỗi: $e");
//     }
//   }

//   void _navigateToRunning(int day) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RunningTracker(
//           day: day,
//           onCompleted: () => _navigateToRest(day),
//         ),
//       ),
//     );
//   }

//   Future<void> _navigateToPushUp(int day) async {
//     if (cameras == null || cameras!.isEmpty) {
//       _showMessage("Không tìm thấy camera");
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PushUpDetectorView(
//           day: day,
//           cameras: cameras!,
//           onCompleted: () => _navigateToRest(day),
//         ),
//       ),
//     );
//   }

//   Future<void> _navigateToSquat(int day) async {
//     if (cameras == null || cameras!.isEmpty) {
//       _showMessage("Không tìm thấy camera");
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SquatDetectorView(
//           day: day,
//           cameras: cameras!,
//           onCompleted: () => _navigateToRest(day),
//         ),
//       ),
//     );
//   }

//   Future<void> _navigateToSitUp(int day) async {
//     if (cameras == null || cameras!.isEmpty) {
//       _showMessage("Không tìm thấy camera");
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SitUpDetectorPage(
//           day: day,
//           cameras: cameras!,
//           onCompleted: () => _navigateToRest(day),
//         ),
//       ),
//     );
//   }

//   void _navigateToRest(int day) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Rest(
//           day: day,
//           onRestCompleted: () => navigateToTraining(day),
//         ),
//       ),
//     );
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Center(
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Đang khởi tạo camera...'),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
