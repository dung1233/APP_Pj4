import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:training_souls/api/workout_apiservice.dart';
import 'package:training_souls/providers/workout_data_service.dart';

import 'package:training_souls/models/work_history.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateRangePickerController _datePickerController;
  final WorkoutApiService _apiService = WorkoutApiService();

  // Map to store dates with completed workouts
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

  // Load workout results from API
  Future<void> _loadWorkoutResults() async {
    if (!mounted) return;

    final workoutDataService =
        Provider.of<WorkoutDataService>(context, listen: false);

    workoutDataService.setLoadingCalendarData(true);

    try {
      // Get all workout results from API
      final List<WorkoutHistory> results =
          await _apiService.getWorkoutHistory();

      // Process results to mark completed days
      Map<DateTime, bool> completedDays = {};

      for (var result in results) {
        try {
          final DateTime completedDate = DateTime.parse(result.createdAt);
          // Store just the date part (without time)
          final DateTime dateOnly = DateTime(
              completedDate.year, completedDate.month, completedDate.day);
          completedDays[dateOnly] = true;
        } catch (parseError) {
          debugPrint("Error parsing date: ${result.createdAt} - $parseError");
        }
      }

      // Cập nhật dữ liệu vào service
      workoutDataService.updateCompletedWorkoutDays(completedDays);
    } catch (e) {
      debugPrint("Error loading workout results: $e");
      errorMessage = "Không thể tải dữ liệu tập luyện. Vui lòng thử lại sau.";
    } finally {
      // Ensure isLoading is set to false
      if (mounted) {
        workoutDataService.setLoadingCalendarData(false);
      }
    }
  }

  // Function to check if a specific date has completed workouts
  bool isCompletedWorkoutDay(DateTime date, WorkoutDataService service) {
    // Remove time part for comparison
    final DateTime dateOnly = DateTime(date.year, date.month, date.day);
    return service.completedWorkoutDays[dateOnly] == true;
  }

  // Function to load workout details for a specific date
  Future<void> _loadWorkoutDetailsForDate(DateTime date) async {
    if (!mounted) return;

    // Lấy service để cập nhật trạng thái
    final workoutDataService =
        Provider.of<WorkoutDataService>(context, listen: false);
    workoutDataService.setLoadingWorkoutDetails(true);

    try {
      // Lấy dữ liệu workout theo ngày từ API
      final List<WorkoutHistory> workouts =
          await _apiService.getWorkoutHistoryByDate(date);

      debugPrint(
          "========== WORKOUTS FOR ${DateFormat('yyyy-MM-dd').format(date)} ==========");
      for (var workout in workouts) {
        debugPrint(workout.toJson().toString());
      }
      debugPrint("===============================================");

      // Cập nhật dữ liệu vào service để OnlineScreen có thể truy cập
      workoutDataService.updateSelectedDateWorkouts(date, workouts);
    } catch (e) {
      debugPrint("Error loading workout details for date $date: $e");
    } finally {
      if (mounted) {
        workoutDataService.setLoadingWorkoutDetails(false);
      }
    }
  }

  // Handle date selection
  void _onDateSelected(DateRangePickerSelectionChangedArgs args) {
    if (args.value is DateTime) {
      final DateTime selectedDate = args.value;
      _loadWorkoutDetailsForDate(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutDataService>(
        builder: (context, workoutDataService, child) {
      return SizedBox(
        width: getWidthPercentage(context, 1),
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
                onSelectionChanged: _onDateSelected,
                cellBuilder: (BuildContext context,
                    DateRangePickerCellDetails cellDetails) {
                  // Check if this date has completed workouts
                  final bool hasCompletedWorkout = isCompletedWorkoutDay(
                      cellDetails.date, workoutDataService);

                  // Today's cell
                  final bool isToday =
                      cellDetails.date.year == DateTime.now().year &&
                          cellDetails.date.month == DateTime.now().month &&
                          cellDetails.date.day == DateTime.now().day;

                  // Is this the selected date?
                  final bool isSelected =
                      workoutDataService.selectedDate != null &&
                          workoutDataService.selectedDate!.year ==
                              cellDetails.date.year &&
                          workoutDataService.selectedDate!.month ==
                              cellDetails.date.month &&
                          workoutDataService.selectedDate!.day ==
                              cellDetails.date.day;

                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.3)
                          : isToday
                              ? Colors.greenAccent
                              : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 1.5)
                          : isToday
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
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
            if (workoutDataService.loadingCalendarData)
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
            if (errorMessage != null && !workoutDataService.loadingCalendarData)
              Container(
                color: Colors.white.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadWorkoutResults,
                        child: const Text("Thử lại"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }
}
