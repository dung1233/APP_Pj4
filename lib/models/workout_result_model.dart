class WorkoutResult {
  final String exerciseName;
  final int setsCompleted;
  final int repsCompleted;
  final double distanceCompleted;
  final int durationCompleted;
  final String status;
  final DateTime createdAt;

  WorkoutResult({
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.distanceCompleted,
    required this.durationCompleted,
    required this.status,
    required this.createdAt,
  });

  factory WorkoutResult.fromJson(Map<String, dynamic> json) {
    return WorkoutResult(
      exerciseName: json['exerciseName'] ?? '',
      setsCompleted: json['setsCompleted'] ?? 0,
      repsCompleted: json['repsCompleted'] ?? 0,
      distanceCompleted: (json['distanceCompleted'] ?? 0.0).toDouble(),
      durationCompleted: json['durationCompleted'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
