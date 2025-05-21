import 'package:flutter/material.dart';
import 'package:training_souls/models/workout_model.dart';
import 'package:training_souls/services/workout_service.dart';

class EditWorkoutScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const EditWorkoutScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final WorkoutService _workoutService = WorkoutService();
  // Map of day number to list of workouts for that day
  final Map<int, List<Workout>> _workoutsByDay = {};
  // Map of day number to list of controllers for that day's workouts
  final Map<int, List<Map<String, TextEditingController>>> _controllersByDay =
      {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWorkouts();
  }

  @override
  void dispose() {
    for (var controllers in _controllersByDay.values) {
      for (var controller in controllers) {
        controller.values.forEach((c) => c.dispose());
      }
    }
    super.dispose();
  }

  void _initializeWorkouts() {
    final now = DateTime.now();

    // Initialize with default workouts
    for (int day = 1; day <= 4; day++) {
      _workoutsByDay[day] = [];
      _controllersByDay[day] = [];

      // Add one default workout for each day
      _addWorkoutToDay(
          day,
          Workout(
            day: day,
            exerciseName: _getDefaultExerciseName(day),
            sets: _getDefaultSets(day),
            reps: _getDefaultReps(day),
            duration: _getDefaultDuration(day),
            distance: _getDefaultDistance(day),
            workoutDate: now.add(Duration(days: day)).toString().split(' ')[0],
            status: 'NOT_STARTED',
          ));
    }
  }

  String _getDefaultExerciseName(int day) {
    switch (day) {
      case 1:
        return 'Chạy bộ';
      case 2:
        return 'Squat';
      case 3:
        return 'Hít đất';
      case 4:
        return 'Gập bụng';
      default:
        return 'Bài tập';
    }
  }

  int _getDefaultSets(int day) {
    switch (day) {
      case 1:
        return 2;
      case 2:
        return 3;
      case 3:
        return 2;
      case 4:
        return 2;
      default:
        return 2;
    }
  }

  int _getDefaultReps(int day) {
    switch (day) {
      case 1:
        return 0;
      case 2:
        return 15;
      case 3:
        return 20;
      case 4:
        return 30;
      default:
        return 0;
    }
  }

  int _getDefaultDuration(int day) {
    switch (day) {
      case 1:
        return 16;
      case 2:
        return 10;
      case 3:
        return 5;
      case 4:
        return 8;
      default:
        return 10;
    }
  }

  double _getDefaultDistance(int day) {
    switch (day) {
      case 1:
        return 3.0;
      default:
        return 0.0;
    }
  }

  void _addWorkoutToDay(int day, Workout workout) {
    setState(() {
      _workoutsByDay[day]!.add(workout);
      _controllersByDay[day]!.add({
        'exerciseName': TextEditingController(text: workout.exerciseName),
        'sets': TextEditingController(text: workout.sets.toString()),
        'reps': TextEditingController(text: workout.reps.toString()),
        'duration': TextEditingController(text: workout.duration.toString()),
        'distance': TextEditingController(text: workout.distance.toString()),
      });
    });
  }

  void _removeWorkout(int day, int index) {
    setState(() {
      // Dispose controllers
      _controllersByDay[day]![index].values.forEach((c) => c.dispose());
      // Remove workout and its controllers
      _workoutsByDay[day]!.removeAt(index);
      _controllersByDay[day]!.removeAt(index);
    });
  }

  Future<void> _saveWorkouts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Collect all workouts from all days
      final List<Workout> allWorkouts = [];

      for (var day in _workoutsByDay.keys) {
        final workouts = _workoutsByDay[day]!;
        final controllers = _controllersByDay[day]!;

        for (var i = 0; i < workouts.length; i++) {
          final workout = workouts[i];
          final controller = controllers[i];

          allWorkouts.add(Workout(
            day: day,
            exerciseName: controller['exerciseName']!.text,
            sets: int.tryParse(controller['sets']!.text) ?? 0,
            reps: int.tryParse(controller['reps']!.text) ?? 0,
            duration: int.tryParse(controller['duration']!.text) ?? 0,
            distance: double.tryParse(controller['distance']!.text) ?? 0,
            workoutDate: workout.workoutDate,
            status: workout.status,
          ));
        }
      }

      await _workoutService.updateWorkout(widget.studentId, allWorkouts);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu lịch tập thành công')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Không thể lưu lịch tập: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildWorkoutCard(int day, int index) {
    final workout = _workoutsByDay[day]![index];
    final controllers = _controllersByDay[day]![index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bài tập ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeWorkout(day, index),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tên bài tập',
                border: OutlineInputBorder(),
              ),
              controller: controllers['exerciseName'],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Số hiệp',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: controllers['sets'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Số lần lặp',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: controllers['reps'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Thời gian (phút)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: controllers['duration'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Quãng đường (km)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: controllers['distance'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch tập cho ${widget.studentName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveWorkouts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveWorkouts,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _workoutsByDay.length,
                  itemBuilder: (context, dayIndex) {
                    final day = dayIndex + 1;
                    final workouts = _workoutsByDay[day]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ngày $day - ${workouts.first.workoutDate}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                final now = DateTime.now();
                                _addWorkoutToDay(
                                    day,
                                    Workout(
                                      day: day,
                                      exerciseName: 'Bài tập mới',
                                      sets: 2,
                                      reps: 10,
                                      duration: 10,
                                      distance: 0,
                                      workoutDate: now
                                          .add(Duration(days: day))
                                          .toString()
                                          .split(' ')[0],
                                      status: 'NOT_STARTED',
                                    ));
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm bài tập'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                          workouts.length,
                          (index) => _buildWorkoutCard(day, index),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
    );
  }
}
