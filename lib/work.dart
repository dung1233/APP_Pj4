import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WorkoutItem extends StatelessWidget {
  final String animationPath; // Đường dẫn Lottie animation
  final String exerciseName; // Tên bài tập
  final int sets; // Số sets
  final int reps; // Số reps

  const WorkoutItem({
    super.key,
    required this.animationPath,
    required this.exerciseName,
    required this.sets,
    required this.reps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            // ✅ Hiển thị animation bên trái
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Lottie.asset(animationPath), // 🔥 Load animation
            ),
            const SizedBox(width: 15),

            // ✅ Nội dung bài tập
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  Text(
                    "Sets: $sets - Reps: $reps",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
