import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../data/DatabaseHelper.dart';
import '../../models/work_out.dart';
import 'detector_view.dart';
import 'painters/pose_painter.dart';
import 'pose_classifier_processor.dart';
import '../User/test3.dart';

class SquatDetectorView extends StatefulWidget {
  final List<Workout> dayWorkouts;
  const SquatDetectorView({super.key, required this.dayWorkouts});
  @override
  State<StatefulWidget> createState() => _SquatDetectorViewState();
}

class _SquatDetectorViewState extends State<SquatDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  final PoseClassifierProcessor _poseClassifierProcessor = PoseClassifierProcessor(isStreamMode: true);
  final dbHelper = DatabaseHelper();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String _exerciseText = "Chưa nhận diện";
  int _repCount = 0;
  Pose? _previousPose;
  var _cameraLensDirection = CameraLensDirection.back;
  late final Workout squatWorkout;
  @override
  void initState() {
    super.initState();
    squatWorkout = widget.dayWorkouts.firstWhere(
          (w) => w.exerciseName?.toLowerCase() == "squat" || w.exerciseName?.toLowerCase() == "squat",
      orElse: () => Workout(sets: 0, reps: 0),
    );
  }
  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget = (squatWorkout.sets ?? 0) * (squatWorkout.reps ?? 0);

    return Stack(
      children: [
        DetectorView(
          title: 'Squat Detector',
          customPaint: _customPaint,
          text: _exerciseText,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bạn đang tập bài Squats", style: TextStyle(fontSize: 18, color: Colors.white)),
              Text("$_exerciseText/$totalTarget",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              Text(
                "${squatWorkout.sets} sets × ${squatWorkout.reps} reps = = $totalTarget",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: SizedBox(
            width: 50,
            height: 50,
            child: FloatingActionButton(
              heroTag: 'next_button',
              backgroundColor: Colors.orange[800],
              onPressed: () async {
                final saved = await _handleNext();
                if (saved && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("✅ Đã lưu kết quả bài tập!")),
                  );
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => WorkoutLocalResultScreen(), // 👉 trang kết quả
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Không thể lưu bài tập.")),
                  );
                }
              },
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }
  Future<bool> _handleNext() async {
    final sets = squatWorkout.sets ?? 0;
    final reps = squatWorkout.reps ?? 0;
    final repFromText = int.tryParse(
      _exerciseText.split(":").last.trim().split(" ").first,
    ) ?? 0;

    final estimatedSets = reps > 0 ? (repFromText ~/ reps) : 0;

    //kiểm tra xem tập đủ chưa để chọn trạng thái
    final totalTarget = (squatWorkout.sets ?? 0) * (squatWorkout.reps ?? 0);
    String status = (repFromText >= totalTarget) ? "COMPLETED" : "IN_PROGRESS";

    if (squatWorkout.exerciseName != null) {
      await dbHelper.insertOrUpdateWorkoutResult(
        dayNumber: squatWorkout.day ?? 0,
        exerciseName: squatWorkout.exerciseName ?? '',
        setsCompleted: estimatedSets,
        repsCompleted: repFromText,
        distanceCompleted: 0.0,
        durationCompleted: 0,
      );
      await dbHelper.updateWorkoutStatusByDayAndExercise(
        dayNumber: squatWorkout.day ?? 0,
        exerciseName: squatWorkout.exerciseName ?? '',
        newStatus: status,
      );

      print("✅ Đã lưu/ghi đè vào local: ${squatWorkout.exerciseName} - $repFromText reps");
      return true;
    }
    return false;
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isNotEmpty && _isValidPose(poses.first)) {
      List<String> classificationResult = _poseClassifierProcessor.getPoseResult(poses.first);

      if (classificationResult.isNotEmpty && _isSignificantMovement(poses.first)) {
        setState(() {
          String detectedExercise = classificationResult[0];
          if (detectedExercise.contains("squats")) {
            _exerciseText = detectedExercise;
            _updateRepCount(classificationResult);
          } else {
            _exerciseText = "Sai tư thế!";
          }
        });
      }
    }

    _updateCanvas(poses, inputImage);
  }

  void _updateRepCount(List<String> classificationResult) {
    if (classificationResult.length > 1) {
      List<String> parts = classificationResult[1].split(" ");
      if (parts.length > 2) {
        int newRepCount = int.tryParse(parts[2]) ?? _repCount;
        if (newRepCount > _repCount) {
          _repCount = newRepCount;
          print("[DEBUG] Squats - Số lần: $_repCount");
        }
      }
    }
  }

  void _updateCanvas(List<Pose> poses, InputImage inputImage) {
    if (poses.isNotEmpty && inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      _customPaint = CustomPaint(
        painter: PosePainter(poses, inputImage.metadata!.size, inputImage.metadata!.rotation, _cameraLensDirection),
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
        validKeypoints++;  // Đếm số keypoints hợp lệ
      }
    }

    return validKeypoints >= 6;  // Cần ít nhất 6 điểm để tránh lỗi nhận diện
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
      if (currentPose.landmarks.containsKey(keypoint) && _previousPose!.landmarks.containsKey(keypoint)) {
        final newPos = currentPose.landmarks[keypoint]!;
        final oldPos = _previousPose!.landmarks[keypoint]!;

        double movement = (newPos.y - oldPos.y).abs();
        totalMovement += movement;
      }
    }

    return totalMovement > 30;
  }
}
