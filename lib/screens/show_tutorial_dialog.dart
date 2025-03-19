import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showTutorialPopup(
    BuildContext context, VoidCallback onConfirm) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Hướng dẫn"),
      content: Text("Bạn có muốn xem hướng dẫn sử dụng ứng dụng không?"),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Đóng popup
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasSeenTutorial', true);
          },
          child: Text("Không"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasSeenTutorial', true);
            onConfirm(); // Gọi hàm hướng dẫn (Showcase)
          },
          child: Text("Có"),
        ),
      ],
    ),
  );
}
//  return Scaffold(
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         child: Container(
//           color: Colors.white,
//           child: Column(
//             children: [
//               IconsUser(userData: widget.userData),
//               Wellcome(),
//               Column(
//                 children: [
//                   if (widget.userData['level'] == 'Beginer')
//                     BeginnerScreen()
//                   else if (widget.userData['level'] == 'Medium')
//                     Intermediate()
//                   else
//                     Text('Error: Unknown Level'),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   ElevatedButton(
//                     style: buttonStyle,
//                     onPressed: () => _scrollToSection(beginnerKey),
//                     child: Text("Beginner",
//                         style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15)),
//                   ),
//                   ElevatedButton(
//                     style: buttonStyle,
//                     onPressed: () => _scrollToSection(mediumKey),
//                     child: Text(
//                       "Medium",
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style: buttonStyle,
//                     onPressed: () => _scrollToSection(hardKey),
//                     child: Text(
//                       "Hard",
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15),
//                     ),
//                   ),
//                 ],
//               ),
//               _buildSection(
//                   beginnerKey, "Beginner Section", BeginnerDataWidget()),
//               _buildSection(mediumKey, "Medium Section", MediumDataWidget()),
//               _buildSection(hardKey, "Hard Section", HardDataWidget()),
//             ],
//           ),
//         ),
//       ),
//     );
