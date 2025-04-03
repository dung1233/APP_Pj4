import 'package:training_souls/screens/Train/slide_item.dart';
import 'package:flutter/material.dart';

class Intermediate extends StatefulWidget {
  const Intermediate({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntermediateState createState() => _IntermediateState();
}

class _IntermediateState extends State<Intermediate> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Chiều cao cố định
      child: PageView(
        children: [
          SlideItem(
            title: "INTERMEDIATE\n7X4 CHALLENGE",
            description: "Power up your  in 12 weeks!",
            imagePath: "assets/img/OP3.jpg",
            onPressd: () {},
          ),
          SlideItem(
            title: "INTERMEDIATE\n7X8 CHALLENGE",
            description: "Enhance strength and build endurance!",
            imagePath: "assets/img/OP4.jpg",
            onPressd: () {},
          ),
          SlideItem(
            title: "INTERMEDIATE\n7X12 CHALLENGE",
            description: "Enhance strength and build endurance!",
            imagePath: "assets/img/OP5.jpg",
            onPressd: () {},
          ),
        ],
      ),
    );
  }
}
