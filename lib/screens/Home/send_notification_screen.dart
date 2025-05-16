import 'package:flutter/material.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'schedule';
  String? _selectedStudentId;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi thông báo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại thông báo',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'schedule',
                    child: Text('Lịch học'),
                  ),
                  DropdownMenuItem(
                    value: 'booking',
                    child: Text('Đặt lịch'),
                  ),
                  DropdownMenuItem(
                    value: 'reminder',
                    child: Text('Nhắc nhở'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Gửi đến',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tất cả học viên')),
                  DropdownMenuItem(value: '1', child: Text('Nguyễn Văn A')),
                  DropdownMenuItem(value: '2', child: Text('Trần Thị B')),
                  DropdownMenuItem(value: '3', child: Text('Lê Văn C')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStudentId = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sendNotification,
                child: const Text('Gửi thông báo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendNotification() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement notification sending logic
      Navigator.pop(context);
    }
  }
}
