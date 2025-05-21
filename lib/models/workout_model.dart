class Workout {
  final int day;
  final String exerciseName;
  final int sets;
  final int reps;
  final int duration;
  final double distance;
  final String workoutDate;
  final String status;

  Workout({
    required this.day,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.distance,
    required this.workoutDate,
    required this.status,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      day: json['day'] ?? 0,
      exerciseName: json['exerciseName'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      duration: json['duration'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      workoutDate: json['workoutDate'] ?? '',
      status: json['status'] ?? 'NOT_STARTED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'distance': distance,
      'workoutDate': workoutDate,
      'status': status,
    };
  }
}
