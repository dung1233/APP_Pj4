import 'package:flutter/material.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'dart:convert';

import 'package:training_souls/data/local_storage.dart';

class EatScreen extends StatefulWidget {
  const EatScreen({Key? key}) : super(key: key);

  @override
  _EatScreenState createState() => _EatScreenState();
}

class _EatScreenState extends State<EatScreen> {
  String? userName;
  bool isLoading = true;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _printDatabaseContent(DatabaseHelper());
  }

  Future<void> _printDatabaseContent(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;

    final userProfiles = await db.query('user_profile');

    if (userProfiles.isNotEmpty) {
      setState(() {
        userData = userProfiles.first; // Gán vào state
        isLoading = false;
      });
    }

    // In ra để kiểm tra
    print("❓ Dữ liệu bảng user_profile:");
    userProfiles.forEach((profile) {
      print(profile);
    });
  }

  // Define colors
  final Color primaryColor = const Color(0xFFFF6B00);
  final Color textColor = const Color(0xFF333333);
  final Color backgroundColor = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildUserCard(),
                    const SizedBox(height: 16),
                    _buildProgressCard(),
                    const SizedBox(height: 16),
                    _buildMealPlanCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "🍽️ Meal Planner",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: primaryColor,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
                color: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/img/avatar.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${userData["gender"] ?? "Unknown"}, ${userData["age"] ?? "?"} years old",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow(
                        "Starting weight", "${userData["weight"] ?? "?"} kg",
                        isWhite: true),
                    _buildInfoRow(
                        "Target weight", "${userData["height"] ?? "?"} cm",
                        isWhite: true),
                    _buildInfoRow(
                        "Fitness Goal", "${userData["fitnessGoal"] ?? "?"}",
                        isWhite: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress Tracking",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "View Details",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildProgressRow(
              "BMI",
              "${(userData["bmi"] as double?)?.toStringAsFixed(1) ?? "?"}",
              Icons.monitor_weight_outlined,
            ),
            _buildProgressRow(
              "BodyFatPercentage",
              "${(userData["bodyFatPercentage"] as double?)?.toStringAsFixed(1) ?? "?"}%",
              Icons.fitness_center,
            ),
            _buildProgressRow(
              "MuscleMassPercentage",
              "${(userData["muscleMassPercentage"] as double?)?.toStringAsFixed(1) ?? "?"}%",
              Icons.accessibility_new,
            ),
            _buildProgressRow(
              "Beginer",
              "${(userData["Beginer"] as double?)?.toStringAsFixed(1) ?? "?"}%",
              Icons.accessibility_new,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Meal Plan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 15),
            _buildMealItem("Breakfast", "Oatmeal with fruits", "7:00 AM"),
            _buildMealItem("Lunch", "Grilled chicken salad", "12:30 PM"),
            _buildMealItem("Snack", "Protein shake", "4:00 PM"),
            _buildMealItem("Dinner", "Salmon with vegetables", "7:00 PM"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isWhite = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isWhite ? Colors.white70 : textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isWhite ? Colors.white : textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, IconData icon,
      {String? change}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
          if (change != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: change.startsWith('+')
                    ? primaryColor.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                change,
                style: TextStyle(
                  color: change.startsWith('+') ? primaryColor : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItem(String meal, String food, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.restaurant, color: primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  food,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
