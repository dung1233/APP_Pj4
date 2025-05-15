import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/screens/Train/rest.dart';
import 'package:training_souls/screens/Train/restb.dart';
import 'package:training_souls/screens/Train/restc.dart';

late List<CameraDescription> cameras;
Future<void> initializeCameras() async {
  cameras = await availableCameras();
}

class SitUpDetectorPage extends StatefulWidget {
  final int day; // Chỉ cần truyền ngày tập

  const SitUpDetectorPage({
    super.key,
    required this.day,
  });

  @override
  State<SitUpDetectorPage> createState() => _SitUpDetectorPageState();
}

class _SitUpDetectorPageState extends State<SitUpDetectorPage> {
  late CameraController _cameraController;
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  int _totalRequiredReps = 0;
  int _totalSets = 0;
  int _currentSet = 1;
  bool _isLoading = true;
  bool _isDetecting = false;
  int _counter = 0;
  String _position = 'down';
  double _latestAngle = 0.0;
  int _upFrames = 0;
  int _downFrames = 0;
  final int _thresholdFrames = 5;
  List<PoseLandmark> _landmarks = [];
  Size _imageSize = Size.zero;
  CameraLensDirection _currentDirection = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _init();

    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    final dbHelper = DatabaseHelper();
    final allWorkouts = await dbHelper.getWorkouts(); // Dùng phương thức có sẵn

    final pushupWorkouts = allWorkouts
        .where((w) => w.day == widget.day && w.exerciseName == "Gập bụng")
        .toList();

    setState(() {
      _totalRequiredReps = pushupWorkouts.fold(
          0, (sum, w) => sum + (w.sets ?? 0) * (w.reps ?? 0));
      _totalSets = pushupWorkouts.fold(0, (sum, w) => sum + (w.sets ?? 0));
      _isLoading = false;
    });
  }

  Future<void> _saveWorkoutResult() async {
    try {
      final dbHelper = DatabaseHelper();

      // Tạo đối tượng kết quả bài tập theo định dạng API của bạn
      final workoutResult = {
        "exerciseName": "Gập bụng", // Changed from "Hít đất" to "Gập bụng"
        "setsCompleted": _currentSet,
        "repsCompleted": _counter,
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

  void _checkWorkoutProgress() {
    int repsSoFar = _counter;
    int oldSet = _currentSet;

    print(
        "[DEBUG] 🔄 Kiểm tra tiến độ: $repsSoFar/$_totalRequiredReps reps | Set: $_currentSet/$_totalSets");

    if (repsSoFar >= _totalRequiredReps) {
      print("[DEBUG] ✅ Đã đủ số lần! Chuyển trang...");
      // Đã hoàn thành toàn bộ bài tập
      _saveWorkoutResult().then((_) => _goToNextPage());
    } else {
      setState(() {
        int repsPerSet = _totalRequiredReps ~/ _totalSets;
        int newSet = (repsSoFar ~/ repsPerSet) + 1;
        print(
            "[DEBUG] 📊 Set mới tính được: $newSet (từ $repsSoFar ~/ $repsPerSet + 1)");
        _currentSet = newSet;

        // Nếu chuyển sang set mới
        if (_currentSet > oldSet) {
          print("[DEBUG] 🔄 Chuyển sang set mới: $_currentSet");

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

  Future<void> _init() async {
    await Permission.camera.request();
    final selectedCamera =
        cameras.firstWhere((c) => c.lensDirection == _currentDirection);
    _cameraController = CameraController(selectedCamera, ResolutionPreset.high);
    await _cameraController.initialize();
    _cameraController.startImageStream(_processCameraImage);
    setState(() {});
  }

  Future<void> _switchCamera() async {
    _cameraController.stopImageStream();
    await _cameraController.dispose();

    setState(() {
      _currentDirection = _currentDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });

    await _init();
  }

  double _calculateAngle(Offset a, Offset b, Offset c) {
    final ab = Offset(b.dx - a.dx, b.dy - a.dy);
    final cb = Offset(b.dx - c.dx, b.dy - c.dy);
    final dotProduct = (ab.dx * cb.dx + ab.dy * cb.dy);
    final magnitudeAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy);
    final magnitudeCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy);
    final cosine = dotProduct / (magnitudeAB * magnitudeCB);
    final angle = acos(cosine.clamp(-1.0, 1.0)) * (180 / pi);
    return angle;
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation90deg,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );

    _imageSize = metadata.size;

    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isNotEmpty) {
      final Pose pose = poses.first;
      _landmarks = pose.landmarks.values.toList();

      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
      final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

      if (leftShoulder != null &&
          leftHip != null &&
          leftKnee != null &&
          rightShoulder != null &&
          rightHip != null &&
          rightKnee != null) {
        final leftAngle = _calculateAngle(
          Offset(leftShoulder.x, leftShoulder.y),
          Offset(leftHip.x, leftHip.y),
          Offset(leftKnee.x, leftKnee.y),
        );

        final rightAngle = _calculateAngle(
          Offset(rightShoulder.x, rightShoulder.y),
          Offset(rightHip.x, rightHip.y),
          Offset(rightKnee.x, rightKnee.y),
        );

        final avgAngle = (leftAngle + rightAngle) / 2.0;

        setState(() {
          _latestAngle = avgAngle;
        });

        if (_position == 'down') {
          if (avgAngle < 90) {
            _upFrames++;
            if (_upFrames >= _thresholdFrames) {
              _position = 'up';
              _upFrames = 0;
            }
          } else {
            _upFrames = 0;
          }
        } else if (_position == 'up') {
          if (avgAngle > 140) {
            _downFrames++;
            if (_downFrames >= _thresholdFrames) {
              _position = 'down';
              _counter++;
              _downFrames = 0;
              _checkWorkoutProgress();
            }
          } else {
            _downFrames = 0;
          }
        }
      }
    }

    _isDetecting = false;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController),
                CustomPaint(
                  painter: PosePainter(
                      _landmarks, _imageSize, MediaQuery.of(context).size),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: Text(
                    'Sit-Ups: $_counter' '/' '$_totalRequiredReps',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  child: Text("Hiệp $_currentSet/$_totalSets",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                Positioned(
                  top: 120,
                  left: 20,
                  child: Text(
                    'Angle: ${_latestAngle.toStringAsFixed(1)}°',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.yellow),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _switchCamera,
                    child: const Icon(Icons.cameraswitch),
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<PoseLandmark> landmarks;
  final Size imageSize;
  final Size canvasSize;

  PosePainter(this.landmarks, this.imageSize, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    Offset scaleOffset(PoseLandmark lm) {
      final dx = lm.x * canvasSize.width / imageSize.width;
      final dy = lm.y * canvasSize.height / imageSize.height;
      return Offset(dx, dy);
    }

    for (final landmark in landmarks) {
      canvas.drawCircle(scaleOffset(landmark), 6, pointPaint);
    }

    void drawLine(PoseLandmarkType a, PoseLandmarkType b) {
      final lmA = landmarks
          .cast<PoseLandmark?>()
          .firstWhere((l) => l?.type == a, orElse: () => null);
      final lmB = landmarks
          .cast<PoseLandmark?>()
          .firstWhere((l) => l?.type == b, orElse: () => null);
      if (lmA != null && lmB != null) {
        canvas.drawLine(scaleOffset(lmA), scaleOffset(lmB), linePaint);
      }
    }

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
