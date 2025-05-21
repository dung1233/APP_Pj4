import 'package:flutter/material.dart';
import 'package:training_souls/models/workout_result_model.dart';
import 'package:training_souls/services/workout_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final String studentId;

  const WorkoutHistoryScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final WorkoutService _workoutService = WorkoutService();
  List<WorkoutResult> _workoutHistory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      final history = await _workoutService.getWorkoutHistory(widget.studentId);
      setState(() {
        _workoutHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Lịch sử tập luyện',
          style: TextStyle(
            color: Color(0xFF1A1F36),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lỗi: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadWorkoutHistory,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _workoutHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có lịch sử tập luyện',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _workoutHistory.length,
                      itemBuilder: (context, index) {
                        final workout = _workoutHistory[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      workout.exerciseName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1F36),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: workout.status == 'COMPLETED'
                                            ? const Color(0xFF10B981)
                                                .withOpacity(0.1)
                                            : const Color(0xFFEF4444)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        workout.status == 'COMPLETED'
                                            ? 'Hoàn thành'
                                            : 'Chưa hoàn thành',
                                        style: TextStyle(
                                          color: workout.status == 'COMPLETED'
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (workout.setsCompleted > 0)
                                  _buildInfoRow(
                                    'Số hiệp',
                                    '${workout.setsCompleted} hiệp',
                                  ),
                                if (workout.repsCompleted > 0)
                                  _buildInfoRow(
                                    'Số lần lặp',
                                    '${workout.repsCompleted} lần',
                                  ),
                                if (workout.distanceCompleted > 0)
                                  _buildInfoRow(
                                    'Quãng đường',
                                    '${workout.distanceCompleted.toStringAsFixed(2)} km',
                                  ),
                                if (workout.durationCompleted > 0)
                                  _buildInfoRow(
                                    'Thời gian',
                                    '${workout.durationCompleted} phút',
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thời gian: ${_formatDateTime(workout.createdAt)}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1F36),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
