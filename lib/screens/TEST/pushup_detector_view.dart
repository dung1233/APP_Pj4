import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/Train/rest.dart';
import 'package:training_souls/screens/ol.dart';
import 'detector_view.dart';
import 'painters/pose_painter.dart';
import 'pose_classifier_processor.dart';

class PushUpDetectorView extends StatefulWidget {
  final int day; // Chỉ cần truyền ngày tập

  const PushUpDetectorView({
    super.key,
    required this.day,
  });

  @override
  State<StatefulWidget> createState() => _PushUpDetectorViewState();
}

class _PushUpDetectorViewState extends State<PushUpDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  final PoseClassifierProcessor _poseClassifierProcessor =
      PoseClassifierProcessor(isStreamMode: true);

  // Thêm các biến quản lý dữ liệu từ database
  int _totalRequiredReps = 0;
  int _totalSets = 0;
  int _currentSet = 1;
  bool _canProcess = true;
  bool _isBusy = false;
  bool _isLoading = true; // Thêm trạng thái loading
  CustomPaint? _customPaint;
  String _exerciseText = "Chưa nhận diện";

  Pose? _previousPose;
  var _cameraLensDirection = CameraLensDirection.back;

  int get _repsPerSet => _totalRequiredReps ~/ _totalSets;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
    // Tải dữ liệu khi khởi tạo
  }

  @override
  void dispose() {
    _canProcess = false;

    _poseDetector.close();
    super.dispose();
  }

  // Thêm các biến này vào phần khai báo biến

  void _checkWorkoutProgress() {
    int repsSoFar = _extractRepCount();
    int oldSet = _currentSet;

    print(
        "[DEBUG] 🔄 Kiểm tra tiến độ: $repsSoFar/$_totalRequiredReps reps | _repsPerSet=$_repsPerSet | _totalSets=$_totalSets");

    if (repsSoFar >= _totalRequiredReps) {
      print("[DEBUG] ✅ Đã đủ số lần! Chuyển trang...");
      // Đã hoàn thành toàn bộ bài tập
      _goToNextPage();
    } else {
      setState(() {
        int newSet = (repsSoFar ~/ _repsPerSet) + 1;
        print(
            "[DEBUG] 📊 Set mới tính được: $newSet (từ $repsSoFar ~/ $_repsPerSet + 1)");
        _currentSet = newSet;

        // Nếu chuyển sang set mới
        if (_currentSet > oldSet) {
          // Reset _exerciseText để đếm lại từ đầu
          _exerciseText = "Chưa nhận diện";
          print(
              "[DEBUG] 🔄 Reset counter khi chuyển sang set mới: $_currentSet");

          // Thông báo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Hoàn thành set $oldSet! Chuẩn bị cho set $_currentSet."),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  Future<void> _saveWorkoutResult() async {
    try {
      final dbHelper = DatabaseHelper();

      // Tạo đối tượng kết quả bài tập theo định dạng API của bạn
      final workoutResult = {
        "exerciseName": "Hít đất",
        "setsCompleted": _currentSet,
        "repsCompleted": _extractRepCount(),
        "distanceCompleted": 0.0,
        "durationCompleted": 0
      };

      // Lưu vào cơ sở dữ liệu
      await dbHelper.saveExerciseResult(widget.day, workoutResult);

      print("[DEBUG] ✅ Đã lưu kết quả tập luyện: ${workoutResult.toString()}");
    } catch (e) {
      print("[DEBUG] ❌ Lỗi khi lưu kết quả: $e");
    }
  }

  void _goToNextPage() async {
    print("[DEBUG] 💾 Đang lưu kết quả tập luyện...");

    // Hiển thị loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Lưu kết quả tập luyện
    await _saveWorkoutResult();

    // Đóng loading dialog
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã lưu kết quả tập luyện!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    print("[DEBUG] 🚀 Đang chuyển sang trang tiếp theo...");
    // Chuyển trang sau khi đã lưu kết quả
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Rest(day: widget.day)),
        );
      }
    });
  }

  // Hàm mới: Lấy dữ liệu từ SQLite
  Future<void> _loadWorkoutData() async {
    final dbHelper = DatabaseHelper();
    final allWorkouts = await dbHelper.getWorkouts(); // Dùng phương thức có sẵn

    final pushupWorkouts = allWorkouts
        .where((w) => w.day == widget.day && w.exerciseName == "Hít đất")
        .toList();

    setState(() {
      _totalRequiredReps = pushupWorkouts.fold(
          0, (sum, w) => sum + (w.sets ?? 0) * (w.reps ?? 0));
      _totalSets = pushupWorkouts.fold(0, (sum, w) => sum + (w.sets ?? 0));
      _isLoading = false;
    });
  }

  int _extractRepCount() {
    try {
      // Tìm số trong chuỗi _exerciseText
      RegExp regExp = RegExp(r'(\d+)');
      var matches = regExp.allMatches(_exerciseText);

      if (matches.isNotEmpty) {
        return int.parse(matches.first.group(0)!);
      }
    } catch (e) {
      print("[DEBUG] ❌ Lỗi khi trích xuất số từ _exerciseText: $e");
    }

    // Trả về 0 nếu không tìm thấy số
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DetectorView(
          title: 'Push-Up Detector',
          customPaint: _customPaint,
          text: _exerciseText,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) {
            setState(() {
              _cameraLensDirection = value;
              _previousPose =
                  null; // ✅ Reset khi đổi camera để tránh lỗi so sánh tọa độ
            });
          },
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bài tập: Hít đất",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              Text("Trạng thái: $_exerciseText",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              Text("Hiệp $_currentSet/$_totalSets",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              // Trong widget build
              Text("Số lần: ${_extractRepCount()}/$_totalRequiredReps",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isNotEmpty) {
      if (!_isValidPose(poses.first)) {
        print("[DEBUG] ❌ Pose không hợp lệ (không đủ keypoints)");
      } else if (!_isSignificantMovement(poses.first)) {
        print("[DEBUG] ❌ Chuyển động quá nhỏ, không tính.");
      } else {
        List<String> classificationResult =
            _poseClassifierProcessor.getPoseResult(poses.first);

        if (classificationResult.isNotEmpty) {
          setState(() {
            _exerciseText = classificationResult[0];
          });

          _checkWorkoutProgress();
        }
      }
    } else {
      print("[DEBUG] ❌ Không phát hiện pose nào!");
    }

    _updateCanvas(poses, inputImage);
  }

  void _updateCanvas(List<Pose> poses, InputImage inputImage) {
    if (poses.isNotEmpty &&
        inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      _customPaint = CustomPaint(
        painter: PosePainter(poses, inputImage.metadata!.size,
            inputImage.metadata!.rotation, _cameraLensDirection),
      );
    } else {
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  /// 🔹 Kiểm tra tư thế hợp lệ
  bool _isValidPose(Pose pose) {
    final requiredKeypoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
    ];

    int validKeypoints = 0;
    for (var keypoint in requiredKeypoints) {
      if (pose.landmarks.containsKey(keypoint)) {
        validKeypoints++;
      }
    }

    print("[DEBUG] ✅ Số keypoints hợp lệ: $validKeypoints");

    if (_cameraLensDirection == CameraLensDirection.front) {
      return validKeypoints >= 4;
    }
    return validKeypoints >= 6;
  }

  /// 🔹 Kiểm tra chuyển động, chỉ giảm ngưỡng nếu dùng camera trước
  bool _isSignificantMovement(Pose currentPose) {
    if (_previousPose == null) return true;

    final keypointsToCheckPushUps = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow
    ];

    double totalMovementZ = 0;
    double totalMovementY = 0;

    for (var keypoint in keypointsToCheckPushUps) {
      if (currentPose.landmarks.containsKey(keypoint) &&
          _previousPose!.landmarks.containsKey(keypoint)) {
        final newPos = currentPose.landmarks[keypoint]!;
        final oldPos = _previousPose!.landmarks[keypoint]!;

        double movementZ = (newPos.z - oldPos.z).abs();
        double movementY = (newPos.y - oldPos.y).abs();
        totalMovementZ += movementZ;
        totalMovementY += movementY;
      }
    }

    print(
        "[DEBUG] ✅ totalMovementZ: $totalMovementZ | totalMovementY: $totalMovementY");

    if (_cameraLensDirection == CameraLensDirection.front) {
      bool isMoving = totalMovementZ > 15 || totalMovementY > 15;
      if (!isMoving) print("[DEBUG] ❌ Chuyển động quá nhỏ, không tính.");
      return isMoving;
    }

    bool isMoving = totalMovementZ > 30 || totalMovementY > 30;
    if (!isMoving) print("[DEBUG] ❌ Chuyển động quá nhỏ, không tính.");
    return isMoving;
  }
}
