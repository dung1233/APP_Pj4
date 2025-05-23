import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/Train/rest.dart';
import 'package:training_souls/screens/Train/restb.dart';
import 'detector_view.dart';
import 'painters/pose_painter.dart';
import 'pose_classifier_processor.dart';

class SquatDetectorView extends StatefulWidget {
  final int day; // Thêm tham số day

  const SquatDetectorView({
    super.key,
    required this.day,
  });
  @override
  State<StatefulWidget> createState() => _SquatDetectorViewState();
}

class _SquatDetectorViewState extends State<SquatDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  final PoseClassifierProcessor _poseClassifierProcessor =
      PoseClassifierProcessor(isStreamMode: true);

  int _totalRequiredReps = 0;
  int _totalSets = 0;
  int _orginalReps = 0;
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
    _loadWorkoutData(); // Tải dữ liệu khi khởi tạo
  }

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
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
      if (kDebugMode) {
        print("[DEBUG] ❌ Lỗi khi trích xuất số từ _exerciseText: $e");
      }
    }

    // Trả về 0 nếu không tìm thấy số
    return 0;
  }

  Future<void> _loadWorkoutData() async {
    final dbHelper = DatabaseHelper();
    final allWorkouts = await dbHelper.getWorkouts();

    final squatWorkouts = allWorkouts
        .where((w) => w.day == widget.day && w.exerciseName == "Squat")
        .toList();

    setState(() {
      _totalRequiredReps = squatWorkouts.fold(
          0, (sum, w) => sum + (w.sets ?? 0) * (w.reps ?? 0));
      _orginalReps =  squatWorkouts.fold(
          0, (sum, w) => sum + (w.reps ?? 0));
      _totalSets = squatWorkouts.fold(0, (sum, w) => sum + (w.sets ?? 0));
      _isLoading = false;
    });
  }

  void _goToNextPage() async {
    if (kDebugMode) {
      print("[DEBUG] 💾 Đang lưu kết quả tập luyện...");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      await _saveWorkoutResult();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      // Chuyển tới trang Rest thay vì bài tập khác
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Rest(day: widget.day),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  Future<void> _saveWorkoutResult() async {
    try {
      final dbHelper = DatabaseHelper();

      // Tạo đối tượng kết quả bài tập
      final workoutResult = {
        "exerciseName": "Squat",
        "setsCompleted": _totalSets,
        "repsCompleted": _orginalReps,
        "distanceCompleted": 0.0,
        "durationCompleted": 0
      };

      // Lưu vào cơ sở dữ liệu
      await dbHelper.saveExerciseResult(widget.day, workoutResult);
      if (kDebugMode) {
        print(
            "[DEBUG] ✅ Đã lưu kết quả tập luyện: ${workoutResult.toString()}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[DEBUG] ❌ Lỗi khi lưu kết quả: $e");
      }
    }
  }

  void _checkWorkoutProgress() {
    int repsSoFar = _extractRepCount();
    int oldSet = _currentSet;

    if (kDebugMode) {
      print(
          "[DEBUG] 🔄 Kiểm tra tiến độ: $repsSoFar/$_totalRequiredReps reps | _repsPerSet=$_repsPerSet | _totalSets=$_totalSets");
    }

    if (repsSoFar >= _totalRequiredReps) {
      if (kDebugMode) {
        print("[DEBUG] ✅ Đã đủ số lần! Chuyển trang...");
      }
      // Đã hoàn thành toàn bộ bài tập
      _goToNextPage();
    } else {
      setState(() {
        int newSet = (repsSoFar ~/ _repsPerSet) + 1;
        if (kDebugMode) {
          print(
              "[DEBUG] 📊 Set mới tính được: $newSet (từ $repsSoFar ~/ $_repsPerSet + 1)");
        }
        _currentSet = newSet;

        // Nếu chuyển sang set mới
        if (_currentSet > oldSet) {
          // Reset _exerciseText để đếm lại từ đầu
          _exerciseText = "Chưa nhận diện";
          if (kDebugMode) {
            print(
                "[DEBUG] 🔄 Reset counter khi chuyển sang set mới: $_currentSet");
          }

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DetectorView(
          title: 'Squat Detector',
          customPaint: _customPaint,
          text: _exerciseText,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) {
            setState(() {
              _cameraLensDirection = value;
              _previousPose = null; // Reset khi đổi camera
            });
          },
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bạn đang tập bài Squats",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              Text("Bài tập: $_exerciseText",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              Text("Hiệp $_currentSet/$_totalSets",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              Text("Số lần: ${_extractRepCount()}/$_totalRequiredReps",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Future _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isNotEmpty) {
      if (!_isValidPose(poses.first)) {
        // Log thông báo khi pose không hợp lệ
        if (kDebugMode) {
          print("[DEBUG] ❌ Pose không hợp lệ (không đủ keypoints)");
        }
      } else if (!_isSignificantMovement(poses.first)) {
        // Log thông báo khi chuyển động quá nhỏ
        if (kDebugMode) {
          print("[DEBUG] ❌ Chuyển động quá nhỏ, không tính.");
        }
      } else {
        List classificationResult =
            _poseClassifierProcessor.getPoseResult(poses.first);

        if (classificationResult.isNotEmpty) {
          setState(() {
            String detectedExercise = classificationResult[0];
            // Kiểm tra và cập nhật kết quả tập luyện nếu có
            if (detectedExercise.contains("squats")) {
              _exerciseText = detectedExercise;
            } else {
              _exerciseText = "Sai tư thế!";
            }
          });

          _checkWorkoutProgress();
        }
      }
    } else {
      // Log khi không phát hiện được pose nào
      if (kDebugMode) {
        print("[DEBUG] ❌ Không phát hiện pose nào!");
      }
    }

    _previousPose = poses.isNotEmpty ? poses.first : null;
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

  /// Kiểm tra tư thế hợp lệ để tránh đếm sai
  bool _isValidPose(Pose pose) {
    final requiredKeypoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle
    ];

    int validKeypoints = 0;
    for (var keypoint in requiredKeypoints) {
      if (pose.landmarks.containsKey(keypoint)) {
        validKeypoints++; // Đếm số keypoints hợp lệ
      }
    }

    return validKeypoints >= 6; // Cần ít nhất 6 điểm để tránh lỗi nhận diện
  }

  bool _isSignificantMovement(Pose currentPose) {
    if (_previousPose == null) return true;

    final keypointsToCheck = [
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee
    ];

    double totalMovement = 0;
    for (var keypoint in keypointsToCheck) {
      if (currentPose.landmarks.containsKey(keypoint) &&
          _previousPose!.landmarks.containsKey(keypoint)) {
        final newPos = currentPose.landmarks[keypoint]!;
        final oldPos = _previousPose!.landmarks[keypoint]!;

        double movement = (newPos.y - oldPos.y).abs();
        totalMovement += movement;
      }
    }

    return totalMovement > 30;
  }
}
