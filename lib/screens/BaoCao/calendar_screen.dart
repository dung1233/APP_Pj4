import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:training_souls/data/DatabaseHelper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateRangePickerController _datePickerController;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Map to store dates with completed workouts
  Map<DateTime, bool> completedWorkoutDays = {};
  bool isLoading = true;
  String? errorMessage;

  // Helper functions for responsive layout
  double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  @override
  void initState() {
    super.initState();
    _datePickerController = DateRangePickerController();
    _datePickerController.displayDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkoutResults();
    });
  }

  // Load workout results from database
  Future<void> _loadWorkoutResults() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get all workout results from database
      final List<Map<String, dynamic>> results =
          await _databaseHelper.getAllWorkoutResults();

      // Process results to mark completed days
      for (var result in results) {
        // Parse the completed_date from ISO8601 string
        if (result['completed_date'] != null) {
          try {
            final DateTime completedDate =
                DateTime.parse(result['completed_date']);
            // Store just the date part (without time)
            final DateTime dateOnly = DateTime(
                completedDate.year, completedDate.month, completedDate.day);
            completedWorkoutDays[dateOnly] = true;
          } catch (parseError) {
            debugPrint(
                "Error parsing date: ${result['completed_date']} - $parseError");
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading workout results: $e");
      errorMessage = "Không thể tải dữ liệu tập luyện. Vui lòng thử lại sau.";
    } finally {
      // Ensure isLoading is set to false
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Function to check if a specific date has completed workouts
  bool isCompletedWorkoutDay(DateTime date) {
    // Remove time part for comparison
    final DateTime dateOnly = DateTime(date.year, date.month, date.day);
    return completedWorkoutDays[dateOnly] == true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidthPercentage(context, 1),
      // Make height more adaptive based on device size
      height: getHeightPercentage(
          context, MediaQuery.of(context).size.height > 700 ? 0.4 : 0.5),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SfDateRangePicker(
              headerHeight: 0,
              controller: _datePickerController,
              backgroundColor: Colors.white,
              selectionShape: DateRangePickerSelectionShape.rectangle,
              cellBuilder: (BuildContext context,
                  DateRangePickerCellDetails cellDetails) {
                // Check if this date has completed workouts
                final bool hasCompletedWorkout =
                    isCompletedWorkoutDay(cellDetails.date);

                // Today's cell
                final bool isToday =
                    cellDetails.date.year == DateTime.now().year &&
                        cellDetails.date.month == DateTime.now().month &&
                        cellDetails.date.day == DateTime.now().day;

                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.greenAccent : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: isToday
                        ? Border.all(color: Colors.green, width: 1)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          cellDetails.date.day.toString(),
                          style: TextStyle(
                            color: cellDetails.date.month ==
                                    cellDetails.visibleDates[15].month
                                ? Colors.black87
                                : Colors.black26,
                          ),
                        ),
                      ),
                      if (hasCompletedWorkout)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Show loading indicator or error message
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.3),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            ),
          // Show error message if any
          if (errorMessage != null && !isLoading)
            Container(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadWorkoutResults,
                      child: Text("Thử lại"),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }
}
