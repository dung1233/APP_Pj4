// ignore: file_names

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:training_souls/screens/BaoCao/calendar_screen.dart';
import 'package:training_souls/screens/BaoCao/header_screen.dart';
import 'package:training_souls/screens/BaoCao/online_screen.dart';
import 'package:training_souls/screens/BaoCao/rank_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedButtonIndex = 0;
  late DateRangePickerController _datePickerController;

  bool showAvg = false;
  DateTime? selectedDate;
  List<Map<String, dynamic>> selectedWorkouts = [];

  void _handleDateSelection(
      DateTime date, List<Map<String, dynamic>> workouts) {
    setState(() {
      selectedDate = date;
      selectedWorkouts = workouts;
    });
  }

  double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getheightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  @override
  void initState() {
    super.initState();
    _datePickerController = DateRangePickerController();
    _datePickerController.displayDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 25,
        automaticallyImplyLeading: false,
        title: const Text('Báo cáo'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Container(
            color: const Color.fromARGB(255, 226, 225, 225),
            child: Column(
              children: [
                HeaderScreen(),
                _buildTabButtons(),
                IndexedStack(
                  index: _selectedButtonIndex,
                  children: [
                    CalendarScreen(),
                    RankScreen(),
                    _buildTime(),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                OnlineScreen()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      color: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCustomButton(0, "Lịch", Icons.date_range),
            _buildCustomButton(1, "Rank", Icons.emoji_events),
            _buildCustomButton(2, "Time", Icons.timelapse),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(int index, String label, IconData icon) {
    bool isSelected = _selectedButtonIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedButtonIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(bottom: BorderSide(color: Colors.green, width: 2))
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildTime() {
    return const Center(
      child: Text(
        'Tính năng đang phát triển ',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
