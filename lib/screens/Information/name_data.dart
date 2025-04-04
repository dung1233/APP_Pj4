// import 'package:app/data/local_storage.dart';
// import 'package:app/screens/Information/birthday.dart';
// import 'package:app/widget/elevatedButton.dart';
// import 'package:flutter/material.dart';

// class NameScreen extends StatefulWidget {
//   const NameScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _NameScreenState createState() => _NameScreenState();
// }

// class _NameScreenState extends State<NameScreen> {
//   final TextEditingController _controller = TextEditingController();
//   bool isButtonEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadName();
//     _controller.addListener(_validateInput);
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_validateInput);
//     _controller.dispose();
//     super.dispose();
//   }

//   void _loadName() async {
//     Map<String, dynamic> userData = await LocalStorage.loadUserData();
//     String saveName = userData['name'] ?? "";
//     setState(() {
//       _controller.text = saveName;
//       isButtonEnabled = saveName.isNotEmpty;
//     });
//   }

//   void _validateInput() {
//     setState(() {
//       isButtonEnabled = _controller.text.trim().isNotEmpty;
//     });
//   }

//   void _onNextPressed() async {
//     await LocalStorage.saveUserData(name: _controller.text.trim());

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const BirthDateScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.white),
//       body: Container(
//         color: Colors.white,
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             const Center(
//               child: SizedBox(
//                 height: 100,
//                 width: 120,
//                 child: Text(
//                   "What's your name?",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 25,
//                     fontWeight: FontWeight.w300,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//             SizedBox(
//               width: 200,
//               child: TextField(
//                 controller: _controller,
//                 textAlign: TextAlign.center,
//                 decoration: const InputDecoration(hintText: 'Enter your name'),
//               ),
//             ),
//             const Spacer(),
//             Buttonscreen(
//               onPressed: isButtonEnabled ? _onNextPressed : null,
//               isEnabled: isButtonEnabled,
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
