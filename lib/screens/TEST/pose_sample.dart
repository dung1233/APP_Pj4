import 'package:flutter/services.dart';
import '../TEST/point3d.dart';
import '../TEST/pose_embedding.dart';

class PoseSample {
  static const int numLandmarks = 33;
  static const int numDims = 3;

  final String name;
  final String className;
  final List<Point3D> landmarks;
  final List<Point3D> embedding;

  PoseSample({
    required this.name,
    required this.className,
    required this.landmarks,
  }) : embedding = PoseEmbedding.getPoseEmbedding(landmarks);

  /// 🔹 Đọc file CSV và trả về danh sách PoseSample
  static Future<List<PoseSample>> loadPoseSamples(String csvPath) async {
    List<PoseSample> poseSamples = [];

    try {
      String csvContent = await rootBundle.loadString(csvPath);
      List<String> lines = csvContent.split('\n');

      for (String line in lines) {
        PoseSample? poseSample = PoseSample.fromCsv(line);
        if (poseSample != null) {
          poseSamples.add(poseSample);
        }
      }
    } catch (e) {
      print("Lỗi khi đọc file CSV: $e");
    }

    return poseSamples;
  }

  /// 🔹 Chuyển một dòng CSV thành PoseSample
  static PoseSample? fromCsv(String csvLine) {
    if (csvLine.trim().isEmpty) return null;
    List<String> tokens = csvLine.split(',');

    // 🔥 Kiểm tra số cột có đúng hay không
    if (tokens.length < (numLandmarks * numDims) + 2) {
      print("⚠️ Lỗi: Dữ liệu CSV không hợp lệ (Số cột không đúng): $csvLine");
      return null;
    }

    String name = tokens[0];
    String className = tokens[1];
    List<Point3D> landmarks = [];

    // 🔥 Kiểm tra index trước khi thêm vào danh sách
    for (int i = 2; i < tokens.length; i += numDims) {
      if (i + 2 >= tokens.length) {
        print("⚠️ Lỗi: Index ngoài phạm vi trong dòng CSV");
        continue; // Bỏ qua dòng lỗi thay vì gây crash
      }

      try {
        double x = double.parse(tokens[i]);
        double y = double.parse(tokens[i + 1]);
        double z = double.parse(tokens[i + 2]);
        landmarks.add(Point3D(x, y, z));
      } catch (e) {
        print("⚠️ Lỗi chuyển đổi tọa độ: $e");
        return null;
      }
    }

    return PoseSample(name: name, className: className, landmarks: landmarks);
  }
}
