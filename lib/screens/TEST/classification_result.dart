class ClassificationResult {
  // Lưu trữ tên class và độ tự tin tương ứng
  final Map<String, double> classConfidences = {};

  /// Lấy tất cả các class đã được phân loại
  Set<String> getAllClasses() {
    return classConfidences.keys.toSet();
  }

  /// Lấy độ tự tin của một class cụ thể
  double getClassConfidence(String className) {
    return classConfidences[className] ?? 0.0;
  }

  /// Lấy class có độ tự tin cao nhất
  String getMaxConfidenceClass() {
    if (classConfidences.isEmpty) return "Unknown";
    return classConfidences.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Tăng độ tự tin của một class cụ thể
  void incrementClassConfidence(String className) {
    classConfidences[className] = (classConfidences[className] ?? 0) + 1;
  }

  /// Đặt độ tự tin của một class cụ thể
  void putClassConfidence(String className, double confidence) {
    classConfidences[className] = confidence;
  }
}