// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dio/dio.dart';
// import 'package:training_souls/data/local_storage.dart';
// import 'package:training_souls/screens/trainhome.dart';
// import 'package:training_souls/Stripe/account_type_dialog.dart';
// import 'package:training_souls/screens/Khampha/teacher_screen.dart';
// import 'package:training_souls/api/user_service.dart';

// class TestRegistrationDialog extends StatefulWidget {
//   final String? selectedTrainerId;
//   final Map<String, Map<String, dynamic>> trainerInfo;
//   final Function(String) onTrainerSelected;
//   final Function(DateTime) onScheduleSuccess;

//   const TestRegistrationDialog({
//     Key? key,
//     this.selectedTrainerId,
//     required this.trainerInfo,
//     required this.onTrainerSelected,
//     required this.onScheduleSuccess,
//   }) : super(key: key);

//   @override
//   State<TestRegistrationDialog> createState() => _TestRegistrationDialogState();
// }

// class _TestRegistrationDialogState extends State<TestRegistrationDialog> {
//   DateTime? _scheduledTime;
//   String? _selectedTrainerId;

//   @override
//   void initState() {
//     super.initState();
//     _selectedTrainerId = widget.selectedTrainerId;
//   }

//   Future<void> _handleTestButtonClick(BuildContext context) async {
//     try {
//       final token = await LocalStorage.getValidToken();
//       if (token == null) {
//         throw Exception("Token không tồn tại");
//       }

//       final dio = Dio();
//       final client = UserService(dio);
//       final response = await client.getMyInfo("Bearer $token");

//       if (response.code == 0 && response.result != null) {
//         final accountType =
//             response.result?.accountType?.toLowerCase() ?? 'basic';

//         if (accountType != 'premium') {
//           _showPremiumRequiredDialog(context);
//         } else {
//           _showTestOptionsDialog(context);
//         }
//       }
//     } catch (e) {
//       print("❌ Lỗi khi kiểm tra loại tài khoản: $e");
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Có lỗi xảy ra: ${e.toString()}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _showPremiumRequiredDialog(BuildContext context) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Dismiss',
//       barrierColor: Colors.black.withOpacity(0.6),
//       transitionDuration: const Duration(milliseconds: 300),
//       pageBuilder: (_, __, ___) {
//         return Center(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Material(
//                 color: Colors.white,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(vertical: 25),
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Color(0xFFFF6F00), Color(0xFFFF6F00)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           const Icon(
//                             Icons.workspace_premium,
//                             color: Colors.white,
//                             size: 48,
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             'Tính năng Premium',
//                             style: GoogleFonts.urbanist(
//                               color: Colors.white,
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         children: [
//                           Text(
//                             'Kiểm tra bởi Huấn luyện viên',
//                             style: GoogleFonts.urbanist(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Tính năng này yêu cầu tài khoản Premium để sử dụng. '
//                             'Nâng cấp ngay để được huấn luyện viên kiểm tra và nhận phản hồi chuyên sâu.',
//                             style: GoogleFonts.urbanist(
//                               fontSize: 16,
//                               color: Colors.grey.shade700,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 24),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildFeatureItem(
//                                   Icons.check_circle_outline,
//                                   'Phản hồi chi tiết',
//                                 ),
//                               ),
//                               Expanded(
//                                 child: _buildFeatureItem(
//                                   Icons.schedule,
//                                   'Phản hồi nhanh',
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildFeatureItem(
//                                   Icons.video_call,
//                                   'Tư vấn trực tiếp',
//                                 ),
//                               ),
//                               Expanded(
//                                 child: _buildFeatureItem(
//                                   Icons.insert_chart,
//                                   'Phân tích dữ liệu',
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 32),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                               showGeneralDialog(
//                                 context: context,
//                                 barrierLabel: 'Dismiss',
//                                 barrierColor: Colors.black.withOpacity(0.5),
//                                 transitionDuration:
//                                     const Duration(milliseconds: 300),
//                                 pageBuilder: (_, __, ___) {
//                                   return AccountTypePopup(
//                                     selectedOption: 'Basic',
//                                     options: ['Basic', 'Premium'],
//                                     onSelected: (selectedType) {
//                                       print(
//                                           "🔶 Người dùng đã chọn gói: $selectedType");
//                                     },
//                                   );
//                                 },
//                                 transitionBuilder: (_, animation, __, child) {
//                                   return Transform.scale(
//                                     scale: animation.value,
//                                     child: Opacity(
//                                       opacity: animation.value,
//                                       child: child,
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFFF6F00),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                               minimumSize: const Size(double.infinity, 50),
//                             ),
//                             child: Text(
//                               'Nâng cấp Premium',
//                               style: GoogleFonts.urbanist(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: Text(
//                               'Để sau',
//                               style: GoogleFonts.urbanist(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       transitionBuilder: (_, animation, __, child) {
//         return FadeTransition(
//           opacity: animation,
//           child: ScaleTransition(
//             scale: CurvedAnimation(
//               parent: animation,
//               curve: Curves.easeOutBack,
//             ),
//             child: child,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFeatureItem(IconData icon, String text) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           color: const Color(0xFFFF6F00),
//           size: 28,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           text,
//           style: GoogleFonts.urbanist(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   void _showTestOptionsDialog(BuildContext context) {
//     if (_scheduledTime != null) {
//       final now = DateTime.now();
//       if (now.isAfter(_scheduledTime!)) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const VideoCallScreen(),
//           ),
//         );
//         return;
//       }
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         if (_scheduledTime != null) {
//           return StatefulBuilder(
//             builder: (context, setState) {
//               final now = DateTime.now();
//               final difference = _scheduledTime!.difference(now);

//               if (difference.isNegative) {
//                 return AlertDialog(
//                   title: Text(
//                     'Sẵn sàng kiểm tra',
//                     style: GoogleFonts.urbanist(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Đã đến giờ kiểm tra',
//                         style: GoogleFonts.urbanist(),
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const VideoCallScreen(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 32,
//                             vertical: 12,
//                           ),
//                         ),
//                         child: Text(
//                           'Vào phòng ngay',
//                           style: GoogleFonts.urbanist(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return AlertDialog(
//                 title: Text(
//                   'Thời gian còn lại',
//                   style: GoogleFonts.urbanist(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Còn ${difference.inHours} giờ ${difference.inMinutes.remainder(60)} phút ${difference.inSeconds.remainder(60)} giây',
//                       style: GoogleFonts.urbanist(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Đã đặt lịch kiểm tra lúc ${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}',
//                       style: GoogleFonts.urbanist(
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text(
//                       'Đóng',
//                       style: GoogleFonts.urbanist(color: Colors.grey),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         }

//         return AlertDialog(
//           title: Text(
//             'Chọn hình thức kiểm tra',
//             style: GoogleFonts.urbanist(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const VideoCallScreen(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                 ),
//                 child: Text(
//                   'Gọi ngay',
//                   style: GoogleFonts.urbanist(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               if (_scheduledTime == null)
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _showScheduleDialog(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 12,
//                     ),
//                   ),
//                   child: Text(
//                     'Đặt lịch',
//                     style: GoogleFonts.urbanist(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 'Hủy',
//                 style: GoogleFonts.urbanist(color: Colors.grey),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showScheduleDialog(BuildContext context) {
//     final now = DateTime.now();

//     // Lưu trữ thời gian đã chọn
//     DateTime? selectedTime;

//     // Xác định thời gian hiện tại cho giới hạn chọn lịch
//     final currentHour = now.hour;
//     final currentMinute = now.minute;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             // Kiểm tra xem thời gian đã chọn có hợp lệ không (không phải thời gian đã qua)
//             bool isTimeValid() {
//               if (selectedTime == null) return false;

//               // Nếu là cùng ngày, kiểm tra giờ và phút
//               if (selectedTime!.year == now.year &&
//                   selectedTime!.month == now.month &&
//                   selectedTime!.day == now.day) {
//                 return selectedTime!.hour > currentHour ||
//                     (selectedTime!.hour == currentHour &&
//                         selectedTime!.minute > currentMinute);
//               }

//               // Nếu là ngày khác, luôn hợp lệ
//               return selectedTime!.isAfter(now);
//             }

//             return AlertDialog(
//               title: Text(
//                 'Chọn thời gian kiểm tra',
//                 style: GoogleFonts.urbanist(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: Container(
//                 width: double.maxFinite,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Chọn huấn luyện viên
//                       Container(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () => _showTrainerSelectionDialog(context),
//                           icon: const Icon(Icons.person),
//                           label: Text(
//                             _selectedTrainerId != null
//                                 ? 'HLV: ${trainerInfo.values.firstWhere((t) => t['id'] == _selectedTrainerId)['name']}'
//                                 : 'Chọn huấn luyện viên',
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _selectedTrainerId != null
//                                 ? Colors.green
//                                 : const Color(0xFFFF6B00),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 12,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Chọn ngày
//                       Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8, horizontal: 12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Chọn ngày:',
//                               style: GoogleFonts.urbanist(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             InkWell(
//                               onTap: () async {
//                                 final DateTime? pickedDate =
//                                     await showDatePicker(
//                                   context: context,
//                                   initialDate: now,
//                                   firstDate: now,
//                                   lastDate: now.add(const Duration(days: 30)),
//                                   builder: (context, child) {
//                                     return Theme(
//                                       data: Theme.of(context).copyWith(
//                                         colorScheme: const ColorScheme.light(
//                                           primary: Color(0xFFFF6B00),
//                                           onPrimary: Colors.white,
//                                         ),
//                                       ),
//                                       child: child!,
//                                     );
//                                   },
//                                 );

//                                 if (pickedDate != null) {
//                                   setState(() {
//                                     if (selectedTime != null) {
//                                       // Giữ nguyên giờ và phút, chỉ cập nhật ngày
//                                       selectedTime = DateTime(
//                                         pickedDate.year,
//                                         pickedDate.month,
//                                         pickedDate.day,
//                                         selectedTime!.hour,
//                                         selectedTime!.minute,
//                                       );
//                                     } else {
//                                       // Nếu chưa chọn giờ, mặc định là giờ hiện tại + 1
//                                       final defaultHour = (now.hour + 1) % 24;
//                                       selectedTime = DateTime(
//                                         pickedDate.year,
//                                         pickedDate.month,
//                                         pickedDate.day,
//                                         defaultHour,
//                                         0,
//                                       );
//                                     }
//                                   });
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 12, horizontal: 16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade100,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       selectedTime != null
//                                           ? '${selectedTime!.day}/${selectedTime!.month}/${selectedTime!.year}'
//                                           : 'Chọn ngày',
//                                       style: GoogleFonts.urbanist(),
//                                     ),
//                                     const Icon(Icons.calendar_today, size: 20),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // Chọn giờ
//                       Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8, horizontal: 12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Chọn giờ:',
//                               style: GoogleFonts.urbanist(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             InkWell(
//                               onTap: () async {
//                                 final TimeOfDay? pickedTime =
//                                     await showTimePicker(
//                                   context: context,
//                                   initialTime: selectedTime != null
//                                       ? TimeOfDay(
//                                           hour: selectedTime!.hour,
//                                           minute: selectedTime!.minute)
//                                       : TimeOfDay(
//                                           hour: (now.hour + 1) % 24, minute: 0),
//                                   builder: (context, child) {
//                                     return Theme(
//                                       data: Theme.of(context).copyWith(
//                                         colorScheme: const ColorScheme.light(
//                                           primary: Color(0xFFFF6B00),
//                                           onPrimary: Colors.white,
//                                         ),
//                                       ),
//                                       child: child!,
//                                     );
//                                   },
//                                 );

//                                 if (pickedTime != null) {
//                                   setState(() {
//                                     if (selectedTime != null) {
//                                       // Giữ nguyên ngày, chỉ cập nhật giờ và phút
//                                       selectedTime = DateTime(
//                                         selectedTime!.year,
//                                         selectedTime!.month,
//                                         selectedTime!.day,
//                                         pickedTime.hour,
//                                         pickedTime.minute,
//                                       );
//                                     } else {
//                                       // Nếu chưa chọn ngày, mặc định là ngày hiện tại
//                                       selectedTime = DateTime(
//                                         now.year,
//                                         now.month,
//                                         now.day,
//                                         pickedTime.hour,
//                                         pickedTime.minute,
//                                       );
//                                     }
//                                   });
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 12, horizontal: 16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade100,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       selectedTime != null
//                                           ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
//                                           : 'Chọn giờ',
//                                       style: GoogleFonts.urbanist(),
//                                     ),
//                                     const Icon(Icons.access_time, size: 20),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Nút đặt lịch
//                       Container(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: (_selectedTrainerId != null &&
//                                   selectedTime != null &&
//                                   isTimeValid())
//                               ? () async {
//                                   try {
//                                     final token =
//                                         await LocalStorage.getValidToken();
//                                     if (token == null) {
//                                       throw Exception("Token không tồn tại");
//                                     }

//                                     // Format date string cho API theo định dạng yyyy-MM-ddTHH:mm:00
//                                     final dateStr = "${selectedTime!.year}-"
//                                         "${selectedTime!.month.toString().padLeft(2, '0')}-"
//                                         "${selectedTime!.day.toString().padLeft(2, '0')}T"
//                                         "${selectedTime!.hour.toString().padLeft(2, '0')}:"
//                                         "${selectedTime!.minute.toString().padLeft(2, '0')}:00";

//                                     final dio = Dio();
//                                     dio.options.headers["Authorization"] =
//                                         "Bearer $token";
//                                     dio.options.headers["Content-Type"] =
//                                         "application/json";

//                                     // Gọi API với endpoint đúng format
//                                     final response = await dio.post(
//                                         "http://54.251.220.228:8080/trainingSouls/notifications/notifyCoachLevelTest/$dateStr");

//                                     if (response.statusCode == 200) {
//                                       this.setState(() {
//                                         _scheduledTime = selectedTime;
//                                       });
//                                       Navigator.pop(context);
//                                       if (!context.mounted) return;
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             'Đã đặt lịch kiểm tra lúc ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} ngày ${selectedTime!.day}/${selectedTime!.month}/${selectedTime!.year} với ${trainerInfo.values.firstWhere((t) => t['id'] == _selectedTrainerId)['name']}',
//                                           ),
//                                           backgroundColor: Colors.green,
//                                         ),
//                                       );
//                                       Navigator.pushAndRemoveUntil(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               const Trainhome(),
//                                         ),
//                                         (Route<dynamic> route) => false,
//                                       );
//                                     } else {
//                                       throw Exception(
//                                           "Lỗi khi gửi thông báo: ${response.statusCode}");
//                                     }
//                                   } catch (e) {
//                                     print("❌ Lỗi khi gửi thông báo: $e");
//                                     if (e is DioException) {
//                                       print(
//                                           "Response data: ${e.response?.data}");
//                                       print(
//                                           "Response status: ${e.response?.statusCode}");
//                                     }
//                                     if (!context.mounted) return;
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                             "Có lỗi xảy ra khi đặt lịch: ${e.toString()}"),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 }
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: (_selectedTrainerId != null &&
//                                     selectedTime != null &&
//                                     isTimeValid())
//                                 ? Colors.green
//                                 : Colors.grey,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 32,
//                               vertical: 16,
//                             ),
//                           ),
//                           child: Text(
//                             'Đặt lịch kiểm tra',
//                             style: GoogleFonts.urbanist(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Thông báo lỗi nếu có
//                       if (selectedTime != null && !isTimeValid())
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: Text(
//                             'Không thể chọn thời gian đã qua. Vui lòng chọn thời gian khác.',
//                             style: GoogleFonts.urbanist(
//                               color: Colors.red,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       if (_selectedTrainerId == null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: Text(
//                             'Vui lòng chọn huấn luyện viên trước khi đặt lịch',
//                             style: GoogleFonts.urbanist(
//                               color: Colors.orange,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     'Hủy',
//                     style: GoogleFonts.urbanist(color: Colors.grey),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showTrainerSelectionDialog(BuildContext context) {
//     if (_selectedTrainerId != null) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(
//               'Thông báo',
//               style: GoogleFonts.urbanist(
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFFFF6F00),
//               ),
//             ),
//             content: Text(
//               'Bạn đã đăng ký huấn luyện viên rồi, không thể thay đổi',
//               style: GoogleFonts.urbanist(),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   'Đã hiểu',
//                   style: GoogleFonts.urbanist(
//                     color: const Color(0xFFFF6F00),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }

//     final PageController pageController = PageController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: EdgeInsets.zero,
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.95,
//             height: MediaQuery.of(context).size.height * 0.8,
//             margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Chọn Huấn luyện viên',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: PageView.builder(
//                     controller: pageController,
//                     itemCount: widget.trainerInfo.length,
//                     itemBuilder: (context, index) {
//                       final trainer =
//                           widget.trainerInfo.values.elementAt(index);
//                       return SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: Image.asset(
//                                 trainer['image'],
//                                 height: 200,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             Text(
//                               trainer['name'],
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               trainer['specialty'],
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(Icons.work_history,
//                                       color: Colors.orange),
//                                   const SizedBox(width: 10),
//                                   Text(
//                                     trainer['experience'],
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             const Text(
//                               'Chứng chỉ',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             ...trainer['certifications'].map<Widget>((cert) =>
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 5),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Icon(Icons.check_circle,
//                                           color: Colors.green, size: 20),
//                                       const SizedBox(width: 10),
//                                       Flexible(
//                                         child: Text(
//                                           cert,
//                                           style: const TextStyle(fontSize: 16),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )),
//                             const SizedBox(height: 20),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   try {
//                                     final token =
//                                         await LocalStorage.getValidToken();
//                                     if (token == null) {
//                                       throw Exception("Token không tồn tại");
//                                     }

//                                     print(
//                                         "🔍 Attempting to select coach with ID: ${trainer['id']}");

//                                     final dio = Dio();
//                                     dio.interceptors.add(LogInterceptor(
//                                       request: true,
//                                       requestHeader: true,
//                                       requestBody: true,
//                                       responseHeader: true,
//                                       responseBody: true,
//                                       error: true,
//                                     ));

//                                     final userService = UserService(dio);
//                                     try {
//                                       await userService.selectCoach(
//                                         "Bearer $token",
//                                         trainer['id'].toString(),
//                                       );

//                                       setState(() {
//                                         _selectedTrainerId = trainer['id'];
//                                       });
//                                       widget.onTrainerSelected(
//                                           trainer['id'].toString());
//                                       Navigator.pop(context);
//                                       _showScheduleDialog(context);
//                                     } catch (e) {
//                                       if (e is DioException &&
//                                           e.response?.statusCode == 500) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           const SnackBar(
//                                             content: Text(
//                                                 "Bạn đã đăng ký huấn luyện viên này hoặc một huấn luyện viên khác rồi"),
//                                             backgroundColor: Colors.orange,
//                                           ),
//                                         );
//                                         Navigator.pop(context);
//                                       } else {
//                                         rethrow;
//                                       }
//                                     }
//                                   } catch (e) {
//                                     print("❌ Lỗi khi chọn huấn luyện viên: $e");
//                                     if (!context.mounted) return;
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                             "Có lỗi xảy ra khi chọn huấn luyện viên: ${e.toString()}"),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFFF6B00),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 32,
//                                     vertical: 12,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   _selectedTrainerId == trainer['id']
//                                       ? 'Đã chọn'
//                                       : 'Chọn huấn luyện viên này',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     widget.trainerInfo.length,
//                     (index) => Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: pageController.hasClients &&
//                                 pageController.page?.round() == index
//                             ? const Color(0xFFFF6B00)
//                             : Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   bool _isTimeSlotAvailable(TimeOfDay slot) {
//     final now = DateTime.now();
//     final slotDateTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       slot.hour,
//       slot.minute,
//     );
//     return now.isBefore(slotDateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => _handleTestButtonClick(context),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: const Color(0xFFFF6F00),
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Text(
//         "Đăng ký kiểm tra",
//         style: GoogleFonts.urbanist(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
