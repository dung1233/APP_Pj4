import 'dart:math';
import '../TEST/point3d.dart';

class PoseEmbedding {
  static const double torsoMultiplier = 2.5;

  /// Chuyển đổi danh sách keypoints thành vector đặc trưng (embedding)
  static List<Point3D> getPoseEmbedding(List<Point3D> landmarks) {
    List<Point3D> normalizedLandmarks = normalize(landmarks);
    return getEmbedding(normalizedLandmarks);
  }

  /// 🔹 Chuẩn hóa dữ liệu pose trước khi so sánh
  static List<Point3D> normalize(List<Point3D> landmarks) {
    List<Point3D> normalizedLandmarks = List.from(landmarks);

    // 🔹 1️⃣ Lấy trung tâm phần hông
    Point3D hipsCenter = average(landmarks[11], landmarks[12]); // leftHip & rightHip

    // 🔹 2️⃣ Dịch chuyển toàn bộ tọa độ về trung tâm hông
    for (int i = 0; i < normalizedLandmarks.length; i++) {
      normalizedLandmarks[i] = subtract(normalizedLandmarks[i], hipsCenter);
    }

    // 🔹 3️⃣ Chuẩn hóa kích thước dựa trên phần thân (torso)
    double scale = 1 / getPoseSize(normalizedLandmarks);
    for (int i = 0; i < normalizedLandmarks.length; i++) {
      normalizedLandmarks[i] = multiply(normalizedLandmarks[i], scale * 100);
    }

    return normalizedLandmarks;
  }

  /// 🔹 Tính toán kích thước cơ thể dựa trên khoảng cách giữa các bộ phận
  static double getPoseSize(List<Point3D> landmarks) {
    Point3D hipsCenter = average(landmarks[11], landmarks[12]); // leftHip & rightHip
    Point3D shouldersCenter = average(landmarks[5], landmarks[6]); // leftShoulder & rightShoulder

    double torsoSize = l2Norm2D(subtract(hipsCenter, shouldersCenter));
    double maxDistance = torsoSize * torsoMultiplier;

    for (var landmark in landmarks) {
      double distance = l2Norm2D(subtract(hipsCenter, landmark));
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }
    return maxDistance;
  }

  /// 🔹 Trích xuất các đặc trưng (embedding) để phân loại tư thế
  static List<Point3D> getEmbedding(List<Point3D> lm) {
    List<Point3D> embedding = [];

    embedding.add(subtract(average(lm[11], lm[12]), average(lm[5], lm[6]))); // Hông - Vai
    embedding.add(subtract(lm[5], lm[7])); // Vai - Khuỷu tay trái
    embedding.add(subtract(lm[6], lm[8])); // Vai - Khuỷu tay phải
    embedding.add(subtract(lm[7], lm[9])); // Khuỷu tay - Cổ tay trái
    embedding.add(subtract(lm[8], lm[10])); // Khuỷu tay - Cổ tay phải
    embedding.add(subtract(lm[11], lm[13])); // Hông - Đầu gối trái
    embedding.add(subtract(lm[12], lm[14])); // Hông - Đầu gối phải
    embedding.add(subtract(lm[13], lm[15])); // Đầu gối - Mắt cá chân trái
    embedding.add(subtract(lm[14], lm[16])); // Đầu gối - Mắt cá chân phải

    return embedding;
  }

  /// 🔹 Tính trung bình của hai điểm
  static Point3D average(Point3D a, Point3D b) {
    return Point3D((a.x + b.x) / 2, (a.y + b.y) / 2, (a.z + b.z) / 2);
  }

  /// 🔹 Trừ hai điểm 3D
  static Point3D subtract(Point3D a, Point3D b) {
    return Point3D(a.x - b.x, a.y - b.y, a.z - b.z);
  }

  /// 🔹 Nhân một điểm 3D với giá trị `scale`
  static Point3D multiply(Point3D a, double scale) {
    return Point3D(a.x * scale, a.y * scale, a.z * scale);
  }

  /// 🔹 Tính khoảng cách Euclidean 2D (bỏ qua trục Z)
  static double l2Norm2D(Point3D point) {
    return sqrt(point.x * point.x + point.y * point.y);
  }
}
