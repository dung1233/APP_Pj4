import 'package:app/screens/Home/app_bar.dart';
import 'package:app/screens/Home/slide_Item.dart';
import 'package:app/screens/Login/login.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> slides = [
    {
      "title": "Choose Your Level",
      "description":
          "One of the most common layout patterns is to arrange widgets vertically or horizontally!",
      "imagePath": "assets/img/banner.jpg"
    },
    {
      "title": "Overcome Challenges",
      "description":
          "Push beyond your limits and face every obstacle head-on with courage and determination!",
      "imagePath": "assets/img/OP4.jpg"
    },
    {
      "title": "Challenge Your Limits",
      "description":
          "Dare to step outside your comfort zone and discover the strength you never knew you had!",
      "imagePath": "assets/img/banner1.jpg"
    }
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Điều hướng sang trang khác
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginScreen()), // Thay NewScreen bằng trang khác của em
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0x0029323d),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.96, // Chiều cao cố định
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: slides.asMap().entries.map((entry) {
                var data = entry.value;
                return SlideItem(
                  title: data["title"]!,
                  description: data["description"]!,
                  imagePath: data["imagePath"]!,
                  onPressd: _nextPage,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
