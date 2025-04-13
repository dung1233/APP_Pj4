import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final double width;

  const BannerImage({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage("assets/img/home.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GetStartedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6F00),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.2,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Get started",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
