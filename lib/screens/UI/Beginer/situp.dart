import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../../../data/DatabaseHelper.dart';
import '../../../models/work_out.dart';
import '../../User/test3.dart';

late List<CameraDescription> cameras;

Future<void> initializeCameras() async {
  cameras = await availableCameras();
}

class SitUpDetectorPage extends StatefulWidget {
  final List<Workout> dayWorkouts;
  const SitUpDetectorPage({super.key, required this.dayWorkouts});

  @override
  State<SitUpDetectorPage> createState() => _SitUpDetectorPageState();
}

class _SitUpDetectorPageState extends State<SitUpDetectorPage> {
  CameraController? _cameraController;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isDetecting = false;
  int _counter = 0;
  String _position = 'down';
  double _latestAngle = 0.0;
  int _upFrames = 0;
  int _downFrames = 0;
  final int _thresholdFrames = 5;
  Size _imageSize = Size.zero;
  CameraLensDirection _currentDirection = CameraLensDirection.back;
  final dbHelper = DatabaseHelper();
  late final Workout sitUpWorkout;

  @override
  void initState() {
    super.initState();
    _init();
    sitUpWorkout = widget.dayWorkouts.firstWhere(
          (w) => w.exerciseName?.toLowerCase() == "sit-up" || w.exerciseName?.toLowerCase() == "gập bụng",
      orElse: () => Workout(sets: 0, reps: 0),
    );
  }

  Future<void> _init() async {
    await Permission.camera.request();
    final selectedCamera = cameras.firstWhere((c) => c.lensDirection == _currentDirection);
    final controller = CameraController(selectedCamera, ResolutionPreset.high);
    await controller.initialize();
    await controller.startImageStream(_processCameraImage);
    if (!mounted) return;
    setState(() {
      _cameraController = controller;
    });
  }

  Future<void> _switchCamera() async {
    final oldController = _cameraController;
    _cameraController = null;
    if (mounted) {
      setState(() {});
      final completer = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
      await completer.future;
    }
    await oldController?.dispose();

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
    if (_isDetecting || _cameraController == null) return;
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

      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
      final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

      if (leftShoulder != null && leftHip != null && leftKnee != null &&
          rightShoulder != null && rightHip != null && rightKnee != null) {

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
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }
  Future<bool> _handleNext() async {
    final sets = sitUpWorkout.sets ?? 0;
    final reps = sitUpWorkout.reps ?? 0;
    final estimatedSets = reps > 0 ? (_counter ~/ reps) : 0;

    if (sitUpWorkout.exerciseName != null) {
      await dbHelper.insertOrUpdateWorkoutResult(
        dayNumber: sitUpWorkout.day ?? 0,
        exerciseName: sitUpWorkout.exerciseName ?? '',
        setsCompleted: estimatedSets,
        repsCompleted: _counter,
        distanceCompleted: 0.0,
        durationCompleted: 0,
      );
      print("✅ Đã lưu/ghi đè vào local: ${sitUpWorkout.exerciseName} - $_counter reps");
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget = (sitUpWorkout.sets ?? 0) * (sitUpWorkout.reps ?? 0);
    if (_cameraController?.value.isInitialized != true) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize!.height,
              height: _cameraController!.value.previewSize!.width,
              child: CameraPreview(_cameraController!),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              "Sit-Ups: $_counter/$totalTarget",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton(
              onPressed: _switchCamera,
              child: const Icon(Icons.cameraswitch),
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
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<PoseLandmark> landmarks;
  final Size imageSize;
  final Size canvasSize;

  PosePainter(this.landmarks, this.imageSize, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}