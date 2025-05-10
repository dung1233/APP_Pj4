import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'dart:convert';

import 'package:training_souls/data/local_storage.dart';

class EatScreen extends StatefulWidget {
  const EatScreen({super.key});

  @override
  State<EatScreen> createState() => _EatScreenState();
}

class _EatScreenState extends State<EatScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  Map<String, dynamic> _userProfile = {};
  List<Map<String, dynamic>> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final db = await dbHelper.database;
      final profiles = await db.query('user_profile');
      if (profiles.isNotEmpty) {
        setState(() {
          _userProfile = profiles.first;
          _generateMealPlan();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Lỗi khi tải thông tin người dùng: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateMealPlan() {
    final double bmi = _userProfile['bmi'] ?? 0;
    final double bodyFat = _userProfile['bodyFatPercentage'] ?? 0;
    final double muscleMass = _userProfile['muscleMassPercentage'] ?? 0;
    final String level = _userProfile['level'] ?? 'Beginer';

    // Tính toán calo cần thiết dựa trên BMI và mục tiêu
    double baseCalories = 2000; // Calo cơ bản
    if (bmi < 18.5) {
      baseCalories *= 1.2; // Tăng calo cho người thiếu cân
    } else if (bmi > 25) {
      baseCalories *= 0.9; // Giảm calo cho người thừa cân
    }

    // Điều chỉnh calo dựa trên tỷ lệ mỡ và cơ
    if (bodyFat > 20) {
      baseCalories *= 0.9; // Giảm calo nếu tỷ lệ mỡ cao
    }
    if (muscleMass < 70) {
      baseCalories *= 1.1; // Tăng calo nếu tỷ lệ cơ thấp
    }

    // Tạo kế hoạch bữa ăn
    _meals = [
      {
        "name": "Breakfast",
        "time": "7:00 AM",
        "meals": _getBreakfastMeals(baseCalories * 0.3, level),
        "calories": (baseCalories * 0.3).round(),
      },
      {
        "name": "Lunch",
        "time": "12:30 PM",
        "meals": _getLunchMeals(baseCalories * 0.35, level),
        "calories": (baseCalories * 0.35).round(),
      },
      {
        "name": "Snack",
        "time": "4:00 PM",
        "meals": _getSnackMeals(baseCalories * 0.15, level),
        "calories": (baseCalories * 0.15).round(),
      },
      {
        "name": "Dinner",
        "time": "7:00 PM",
        "meals": _getDinnerMeals(baseCalories * 0.2, level),
        "calories": (baseCalories * 0.2).round(),
      },
    ];
  }

  List<String> _getBreakfastMeals(double calories, String level) {
    if (level == 'Beginer') {
      return [
        "Yến mạch với sữa tươi và chuối",
        "Trứng luộc (2 quả)",
        "Sữa chua Hy Lạp",
      ];
    } else {
      return [
        "Yến mạch với whey protein",
        "Trứng ốp la (3 quả)",
        "Bánh mì ngũ cốc nguyên hạt",
      ];
    }
  }

  List<String> _getLunchMeals(double calories, String level) {
    if (level == 'Beginer') {
      return [
        "Cơm gạo lứt",
        "Ức gà nướng",
        "Rau xanh trộn",
      ];
    } else {
      return [
        "Cơm gạo lứt",
        "Cá hồi nướng",
        "Rau củ hấp",
        "Salad rau xanh",
      ];
    }
  }

  List<String> _getSnackMeals(double calories, String level) {
    if (level == 'Beginer') {
      return [
        "Sữa chua trái cây",
        "Hạt hạnh nhân",
      ];
    } else {
      return [
        "Whey protein shake",
        "Chuối",
        "Hạt mix",
      ];
    }
  }

  List<String> _getDinnerMeals(double calories, String level) {
    if (level == 'Beginer') {
      return [
        "Cơm gạo lứt",
        "Thịt bò xào rau",
        "Canh rau",
      ];
    } else {
      return [
        "Khoai lang",
        "Ức gà nướng",
        "Rau xanh",
        "Súp rau",
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kế hoạch dinh dưỡng',
                  style: GoogleFonts.urbanist(
                    color: Color(0xFFFF6B00),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Dựa trên thông tin của bạn:',
                  style: GoogleFonts.urbanist(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                _buildUserInfo(),
                const SizedBox(height: 20),
                ..._meals.map((meal) => _buildMealSection(meal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 25, 25),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildInfoRow(
              "BMI", "${_userProfile['bmi']?.toStringAsFixed(1) ?? 'N/A'}"),
          _buildInfoRow("Tỷ lệ mỡ",
              "${_userProfile['bodyFatPercentage']?.toStringAsFixed(1) ?? 'N/A'}%"),
          _buildInfoRow("Tỷ lệ cơ",
              "${_userProfile['muscleMassPercentage']?.toStringAsFixed(1) ?? 'N/A'}%"),
          _buildInfoRow("Cấp độ", _userProfile['level'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.urbanist(
              color: Color(0xFFFF6B00),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(Map<String, dynamic> meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 25, 25),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal['name'],
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                meal['time'],
                style: GoogleFonts.urbanist(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...(meal['meals'] as List<String>).map((food) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Color(0xFFFF6B00)),
                    const SizedBox(width: 10),
                    Text(
                      food,
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          Text(
            "${meal['calories']} calories",
            style: GoogleFonts.urbanist(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
