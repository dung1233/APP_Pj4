import 'dart:collection';
import 'classification_result.dart';

class EMASmoothing {
  static const int defaultWindowSize = 10;
  static const double defaultAlpha = 0.2;
  static const int resetThresholdMs = 100;

  final int windowSize;
  final double alpha;
  final Queue<ClassificationResult> window;

  int lastInputMs = DateTime.now().millisecondsSinceEpoch;

  EMASmoothing({this.windowSize = defaultWindowSize, this.alpha = defaultAlpha})
      : window = ListQueue(defaultWindowSize);

  ClassificationResult getSmoothedResult(ClassificationResult classificationResult) {
    int nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - lastInputMs > resetThresholdMs) {
      window.clear();
    }
    lastInputMs = nowMs;

    if (window.length == windowSize) {
      window.removeLast();
    }
    window.addFirst(classificationResult);

    Set<String> allClasses = {};
    for (var result in window) {
      allClasses.addAll(result.getAllClasses());
    }

    ClassificationResult smoothedResult = ClassificationResult();

    for (var className in allClasses) {
      double factor = 1;
      double topSum = 0;
      double bottomSum = 0;

      for (var result in window) {
        double value = result.getClassConfidence(className);
        topSum += factor * value;
        bottomSum += factor;
        factor *= (1.0 - alpha);
      }
      smoothedResult.putClassConfidence(className, topSum / bottomSum);
    }

    return smoothedResult;
  }
}
