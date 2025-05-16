import 'package:flutter/material.dart';
import 'package:training_souls/models/schedule_model.dart';
import 'package:training_souls/screens/video/videoCall.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<Schedule> schedules = [
    Schedule(
      id: '1',
      studentId: '1',
      studentName: 'Nguyễn Văn A',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      type: 'One-on-One',
      status: 'upcoming',
    ),
    Schedule(
      id: '2',
      studentId: '2',
      studentName: 'Trần Thị B',
      startTime: DateTime.now().add(const Duration(hours: 3)),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      type: 'One-on-One',
      status: 'upcoming',
    ),
    Schedule(
      id: '3',
      studentId: '3',
      studentName: 'Lê Văn C',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      type: 'One-on-One',
      status: 'upcoming',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getSchedulesForDate().length,
              itemBuilder: (context, index) {
                final schedule = _getSchedulesForDate()[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(schedule.status),
                      child: Text(
                        schedule.studentName[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(schedule.studentName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour}:${schedule.endTime.minute.toString().padLeft(2, '0')}',
                        ),
                        Text(
                          schedule.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (schedule.status == 'upcoming')
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoCallScreen(
                                    studentId: schedule.studentId,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Bắt đầu'),
                          ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            _showScheduleOptions(context, schedule);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Schedule> _getSchedulesForDate() {
    return schedules.where((schedule) {
      return schedule.startTime.year == _selectedDate.year &&
          schedule.startTime.month == _selectedDate.month &&
          schedule.startTime.day == _selectedDate.day;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showScheduleOptions(BuildContext context, Schedule schedule) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Sửa lịch'),
                onTap: () {
                  Navigator.pop(context);
                  _editSchedule(schedule);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Hủy lịch'),
                onTap: () {
                  Navigator.pop(context);
                  _cancelSchedule(schedule);
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_add),
                title: const Text('Thêm ghi chú'),
                onTap: () {
                  Navigator.pop(context);
                  _addNote(schedule);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addNewSchedule() {
    // Navigate to add schedule screen
  }

  void _editSchedule(Schedule schedule) {
    // Navigate to edit schedule screen
  }

  void _cancelSchedule(Schedule schedule) {
    // Cancel schedule logic
  }

  void _addNote(Schedule schedule) {
    // Add note logic
  }
}
