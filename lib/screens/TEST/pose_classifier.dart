import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'pose_sample.dart';
import 'pose_embedding.dart';
import 'classification_result.dart';
import 'point3d.dart';

class PoseClassifier {
  static const int maxDistanceTopK = 30;
  static const int meanDistanceTopK = 10;
  static final Point3D axesWeights = Point3D(1, 1, 0.2);

  final List<PoseSample> poseSamples;

  PoseClassifier(this.poseSamples);

  /// Trích xuất tọa độ keypoints từ tư thế của người dùng
  static List<Point3D> extractPoseLandmarks(Pose pose) {
    List<Point3D> landmarks = [];
    for (var landmark in pose.landmarks.values) {
      landmarks.add(Point3D(landmark.x, landmark.y, landmark.z));
    }
    return landmarks;
  }

  /// Trả về phạm vi độ tin cậy tối đa
  int confidenceRange() {
    return min(maxDistanceTopK, meanDistanceTopK);
  }

  /// Phân loại tư thế người dùng
  ClassificationResult classify(Pose pose) {
    return classifyWithLandmarks(extractPoseLandmarks(pose));
  }

  ClassificationResult classifyWithLandmarks(List<Point3D> landmarks) {
    ClassificationResult result = ClassificationResult();
    if (landmarks.isEmpty) return result;

    List<Point3D> flippedLandmarks = landmarks.map((p) => Point3D(-p.x, p.y, p.z)).toList();
    List<Point3D> embedding = PoseEmbedding.getPoseEmbedding(landmarks);
    List<Point3D> flippedEmbedding = PoseEmbedding.getPoseEmbedding(flippedLandmarks);

    List<MapEntry<PoseSample, double>> maxDistances = [];
    for (PoseSample sample in poseSamples) {
      List<Point3D> sampleEmbedding = sample.embedding;
      double originalMax = 0, flippedMax = 0;
      for (int i = 0; i < embedding.length; i++) {
        originalMax = max(originalMax, _maxAbs(_multiply(_subtract(embedding[i], sampleEmbedding[i]), axesWeights)));
        flippedMax = max(flippedMax, _maxAbs(_multiply(_subtract(flippedEmbedding[i], sampleEmbedding[i]), axesWeights)));
      }
      double minDistance = min(originalMax, flippedMax);
      maxDistances.add(MapEntry(sample, minDistance));
      if (maxDistances.length > maxDistanceTopK) {
        maxDistances.sort((a, b) => a.value.compareTo(b.value));
        maxDistances.removeLast();
      }
    }

    List<MapEntry<PoseSample, double>> meanDistances = [];
    for (var sampleDist in maxDistances) {
      PoseSample sample = sampleDist.key;
      List<Point3D> sampleEmbedding = sample.embedding;
      double originalSum = 0, flippedSum = 0;
      for (int i = 0; i < embedding.length; i++) {
        originalSum += _sumAbs(_multiply(_subtract(embedding[i], sampleEmbedding[i]), axesWeights));
        flippedSum += _sumAbs(_multiply(_subtract(flippedEmbedding[i], sampleEmbedding[i]), axesWeights));
      }
      double meanDistance = min(originalSum, flippedSum) / (embedding.length * 2);
      meanDistances.add(MapEntry(sample, meanDistance));
      if (meanDistances.length > meanDistanceTopK) {
        meanDistances.sort((a, b) => a.value.compareTo(b.value));
        meanDistances.removeLast();
      }
    }

    for (var sampleDist in meanDistances) {
      result.incrementClassConfidence(sampleDist.key.className);
    }

    return result;
  }

  double _maxAbs(Point3D p) {
    return max(p.x.abs(), max(p.y.abs(), p.z.abs()));
  }

  double _sumAbs(Point3D p) {
    return p.x.abs() + p.y.abs() + p.z.abs();
  }

  Point3D _subtract(Point3D a, Point3D b) {
    return Point3D(a.x - b.x, a.y - b.y, a.z - b.z);
  }

  Point3D _multiply(Point3D a, Point3D b) {
    return Point3D(a.x * b.x, a.y * b.y, a.z * b.z);
  }
}
