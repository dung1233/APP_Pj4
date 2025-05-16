class Schedule {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String status;

  Schedule({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
  });
}
