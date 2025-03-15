// ignore: file_names
import 'package:flutter/material.dart';

class SlideItem extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onPressd; // onPressd bắt buộc

  const SlideItem({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onPressd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity, // Đảm bảo Container full màn hình
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // ignore: deprecated_member_use
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: onPressd, // Gọi hàm onPressd từ HomePage
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
