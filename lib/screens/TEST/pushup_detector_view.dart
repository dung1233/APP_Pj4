import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'detector_view.dart';
import 'painters/pose_painter.dart';
import 'pose_classifier_processor.dart';

class PushUpDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PushUpDetectorViewState();
}

class _PushUpDetectorViewState extends State<PushUpDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  final PoseClassifierProcessor _poseClassifierProcessor = PoseClassifierProcessor(isStreamMode: true);

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String _exerciseText = "Chưa nhận diện";
  int _repCount = 0;
  Pose? _previousPose;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
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
              _previousPose = null; // ✅ Reset khi đổi camera để tránh lỗi so sánh tọa độ
            });
          },
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bạn đang tập bài Pushup", style: TextStyle(fontSize: 18, color: Colors.white)),
              Text("Bài tập: $_exerciseText", style: TextStyle(fontSize: 18, color: Colors.white)),
              Text("Số lần: $_repCount", style: TextStyle(fontSize: 18, color: Colors.white)),
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
        List<String> classificationResult = _poseClassifierProcessor.getPoseResult(poses.first);

        if (classificationResult.isNotEmpty) {
          setState(() {
            String detectedExercise = classificationResult[0];
            if (detectedExercise.contains("pushups")) {
              _exerciseText = detectedExercise;
              _updateRepCount(classificationResult);
            } else {
              _exerciseText = "Bạn đang thực hiện sai tư thế!";
              print("[DEBUG] ❌ Bài tập nhận diện không phải chống đẩy!");
            }
          });
        }
      }
    } else {
      print("[DEBUG] ❌ Không phát hiện pose nào!");
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
          print("[DEBUG] ✅ Đếm push-ups: $_repCount");
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
      if (currentPose.landmarks.containsKey(keypoint) && _previousPose!.landmarks.containsKey(keypoint)) {
        final newPos = currentPose.landmarks[keypoint]!;
        final oldPos = _previousPose!.landmarks[keypoint]!;

        double movementZ = (newPos.z - oldPos.z).abs();
        double movementY = (newPos.y - oldPos.y).abs();
        totalMovementZ += movementZ;
        totalMovementY += movementY;
      }
    }

    print("[DEBUG] ✅ totalMovementZ: $totalMovementZ | totalMovementY: $totalMovementY");

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
