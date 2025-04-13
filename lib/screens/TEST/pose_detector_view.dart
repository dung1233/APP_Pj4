import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'detector_view.dart';
import 'painters/pose_painter.dart';
import 'pose_classifier_processor.dart';
// có thể nhận diện cả chống đẩy lần squats và phân biệt được đếm được
//Nhưng camera trước đang bị lỗi không đếm được và nhận diện ko được chống đẩy
//Còn squats thì cả 2 camera đều hoàn thành nhiệm vụ
class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
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
          title: 'Pose Detector',
          customPaint: _customPaint,
          text: _exerciseText,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),

        // Hiển thị số lần thực hiện bài tập
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

    if (poses.isNotEmpty && _isValidPose(poses.first)) {
      List<String> classificationResult = _poseClassifierProcessor.getPoseResult(poses.first);

      if (classificationResult.isNotEmpty && _isSignificantMovement(poses.first)) {
        setState(() {
          _exerciseText = classificationResult[0];

          if (classificationResult.length > 1) {
            List<String> parts = classificationResult[1].split(" ");
            if (parts.length > 2) {
              int newRepCount = int.tryParse(parts[2]) ?? _repCount;
              if (newRepCount > _repCount) {
                _repCount = newRepCount;
                print("[DEBUG] Bài tập: $_exerciseText - Số lần: $_repCount");
              }
            }
          }
        });
      }

      _previousPose = poses.first;
    }

    if (poses.isNotEmpty && inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      _customPaint = CustomPaint(
        painter: PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        ),
      );
    } else {
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  /// 🔹 Kiểm tra tư thế hợp lệ để tránh lỗi đếm bàn tay
  bool _isValidPose(Pose pose) {
    final requiredKeypoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
      PoseLandmarkType.nose, // Thêm điều kiện nhận diện toàn bộ cơ thể
    ];

    int validKeypoints = 0;
    for (var keypoint in requiredKeypoints) {
      if (pose.landmarks.containsKey(keypoint)) {
        validKeypoints++;
      }
    }

    return validKeypoints >= 8; // Yêu cầu ít nhất 8 điểm để hợp lệ
  }

  /// 🔹 Kiểm tra xem người dùng có thực sự di chuyển hay không
  bool _isSignificantMovement(Pose currentPose) {
    if (_previousPose == null) return true;

    final keypointsToCheckSquats = [
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee
    ];

    final keypointsToCheckPushUps = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow
    ];

    double totalMovementY = 0;
    double totalMovementZ = 0;

    // 🔹 Kiểm tra chuyển động theo Y (Squats)
    for (var keypoint in keypointsToCheckSquats) {
      if (currentPose.landmarks.containsKey(keypoint) && _previousPose!.landmarks.containsKey(keypoint)) {
        final newPos = currentPose.landmarks[keypoint]!;
        final oldPos = _previousPose!.landmarks[keypoint]!;
        double movement = (newPos.y - oldPos.y).abs();
        totalMovementY += movement;
      }
    }

    // 🔹 Kiểm tra chuyển động theo Z và Y (Push-ups)
    for (var keypoint in keypointsToCheckPushUps) {
      if (currentPose.landmarks.containsKey(keypoint) && _previousPose!.landmarks.containsKey(keypoint)) {
        final newPos = currentPose.landmarks[keypoint]!;
        final oldPos = _previousPose!.landmarks[keypoint]!;
        double movementZ = (newPos.z - oldPos.z).abs();
        double movementY = (newPos.y - oldPos.y).abs();
        totalMovementZ += movementZ + movementY; // Kết hợp cả hai
      }
    }

    return totalMovementY > 30 || totalMovementZ > 20; // Giảm ngưỡng để nhận diện nhanh hơn
  }
}
