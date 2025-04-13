import 'classification_result.dart';

class RepetitionCounter {
  static const double defaultEnterThreshold = 6.0; // Ngưỡng vào
  static const double defaultExitThreshold = 4.0; // Ngưỡng ra

  final String className;
  final double enterThreshold;
  final double exitThreshold;

  int _numRepeats = 0;
  bool _poseEntered = false;

  RepetitionCounter(this.className, {this.enterThreshold = defaultEnterThreshold, this.exitThreshold = defaultExitThreshold});

  /// Nhận kết quả phân loại và cập nhật số lần thực hiện bài tập.
  int addClassificationResult(ClassificationResult classificationResult) {
    double poseConfidence = classificationResult.getClassConfidence(className);

    if (!_poseEntered) {
      _poseEntered = poseConfidence > enterThreshold;
      return _numRepeats;
    }

    if (poseConfidence < exitThreshold) {
      _numRepeats++;
      _poseEntered = false;
    }

    return _numRepeats;
  }

  String getClassName() => className;

  int getNumRepeats() => _numRepeats;
}
