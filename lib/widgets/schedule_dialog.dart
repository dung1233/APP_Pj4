import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/trainhome.dart';

class ScheduleDialog extends StatefulWidget {
  final Function(DateTime) onScheduleSuccess;
  final Function() onSelectTrainer;

  const ScheduleDialog({
    Key? key,
    required this.onScheduleSuccess,
    required this.onSelectTrainer,
  }) : super(key: key);

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  DateTime? selectedTime;
  final now = DateTime.now();

  bool isTimeValid() {
    if (selectedTime == null) return false;
    return selectedTime!.isAfter(now);
  }

  Future<void> _trySchedule() async {
    if (!isTimeValid()) return;

    try {
      final token = await LocalStorage.getValidToken();
      if (token == null) {
        throw Exception("Token không tồn tại");
      }

      final dateStr = "${selectedTime!.year}-"
          "${selectedTime!.month.toString().padLeft(2, '0')}-"
          "${selectedTime!.day.toString().padLeft(2, '0')}T"
          "${selectedTime!.hour.toString().padLeft(2, '0')}:"
          "${selectedTime!.minute.toString().padLeft(2, '0')}:00";

      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.headers["Content-Type"] = "application/json";

      // Proceed with scheduling directly - simplified flow
      try {
        final response = await dio.post(
            "http://54.251.220.228:8080/trainingSouls/notifications/notifyCoachLevelTest/$dateStr");

        if (response.statusCode == 200) {
          widget.onScheduleSuccess(selectedTime!);
          if (!context.mounted) return;
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Trainhome()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        // Nếu API trả về lỗi 500, chúng ta giả định đó là lỗi "không có huấn luyện viên"
        // và mở dialog chọn huấn luyện viên
        if (e is DioException && e.response?.statusCode == 500) {
          if (!context.mounted) return;
          // In ra log để debug
          print("Gặp lỗi 500 từ API: ${e.response?.data}");

          // Đóng dialog hiện tại và mở dialog chọn huấn luyện viên
          Navigator.pop(context);

          // Đảm bảo onSelectTrainer được gọi sau khi Navigator.pop hoàn thành
          Future.delayed(Duration(milliseconds: 100), () {
            if (context.mounted) {
              widget.onSelectTrainer();
            }
          });
          return;
        } else {
          // Các lỗi khác
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Có lỗi xảy ra khi đặt lịch: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
          print("Có lỗi xảy ra khi đặt lịch: ${e.toString()}");
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chọn thời gian kiểm tra',
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chọn ngày
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn ngày:',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 30)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFFF6B00),
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setState(() {
                            if (selectedTime != null) {
                              selectedTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                selectedTime!.hour,
                                selectedTime!.minute,
                              );
                            } else {
                              final defaultHour = (now.hour + 1) % 24;
                              selectedTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                defaultHour,
                                0,
                              );
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.day}/${selectedTime!.month}/${selectedTime!.year}'
                                  : 'Chọn ngày',
                              style: GoogleFonts.urbanist(),
                            ),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Chọn giờ
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn giờ:',
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime != null
                              ? TimeOfDay(
                                  hour: selectedTime!.hour,
                                  minute: selectedTime!.minute)
                              : TimeOfDay(hour: (now.hour + 1) % 24, minute: 0),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFFF6B00),
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          setState(() {
                            if (selectedTime != null) {
                              selectedTime = DateTime(
                                selectedTime!.year,
                                selectedTime!.month,
                                selectedTime!.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            } else {
                              selectedTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Chọn giờ',
                              style: GoogleFonts.urbanist(),
                            ),
                            const Icon(Icons.access_time, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Nút đặt lịch
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedTime != null && isTimeValid()
                      ? _trySchedule
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTime != null && isTimeValid()
                        ? Colors.green
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    'Tiếp tục',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (selectedTime != null && !isTimeValid())
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Không thể chọn thời gian đã qua. Vui lòng chọn thời gian khác.',
                    style: GoogleFonts.urbanist(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Hủy',
            style: GoogleFonts.urbanist(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
