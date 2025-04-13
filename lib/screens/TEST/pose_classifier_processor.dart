import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'classification_result.dart';
import 'pose_classifier.dart';
import 'pose_sample.dart';
import 'ema_smoothing.dart';
import 'repetition_counter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseClassifierProcessor {
  static const String poseSamplesFile = 'assets/pose/fitness_pose_samples.csv';

  static const String pushupsClass = 'pushups_down';
  static const String squatsClass = 'squats_down';
  static const List<String> poseClasses = [pushupsClass, squatsClass];

  final bool isStreamMode;
  late PoseClassifier poseClassifier;
  EMASmoothing? emaSmoothing;
  List<RepetitionCounter>? repCounters;
  String lastRepResult = "";

  PoseClassifierProcessor({required this.isStreamMode}) {
    if (isStreamMode) {
      emaSmoothing = EMASmoothing();
      repCounters = poseClasses.map((className) => RepetitionCounter(className)).toList();
    }
    _loadPoseSamples();
  }

  Future<void> _loadPoseSamples() async {
    List<PoseSample> poseSamples = [];
    try {
      final csvContent = await rootBundle.loadString(poseSamplesFile);
      final lines = LineSplitter.split(csvContent);
      for (var line in lines) {
        final poseSample = PoseSample.fromCsv(line);
        if (poseSample != null) {
          poseSamples.add(poseSample);
        }
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu mẫu tư thế: $e");
    }
    poseClassifier = PoseClassifier(poseSamples);
  }

  List<String> getPoseResult(Pose pose) {
    List<String> result = [];
    ClassificationResult classification = poseClassifier.classify(pose);

    if (isStreamMode && emaSmoothing != null) {
      classification = emaSmoothing!.getSmoothedResult(classification);
      if (pose.landmarks.isEmpty) {
        result.add(lastRepResult);
        return result;
      }

      for (var repCounter in repCounters!) {
        int repsBefore = repCounter.getNumRepeats();
        int repsAfter = repCounter.addClassificationResult(classification);
        if (repsAfter > repsBefore) {
          lastRepResult = "${repCounter.className} : $repsAfter reps";
          break;
        }
      }
      result.add(lastRepResult);
    }

    if (pose.landmarks.isNotEmpty) {
      String maxConfidenceClass = classification.getMaxConfidenceClass();
      String maxConfidenceClassResult =
          "$maxConfidenceClass : ${classification.getClassConfidence(maxConfidenceClass) / poseClassifier.confidenceRange()} confidence";
      result.add(maxConfidenceClassResult);
    }

    return result;
  }
}
