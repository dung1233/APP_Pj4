// import 'package:training_souls/screens/TEST/pushup_detector_view.dart';
// import 'package:training_souls/screens/TEST/squat_detector_view.dart';
// import 'package:training_souls/screens/UI/Beginer/run.dart';
// import 'package:training_souls/screens/UI/Beginer/situp.dart';

// import 'package:flutter/material.dart';

// class AIMyWidget extends StatefulWidget {
//   const AIMyWidget({super.key});

//   @override
//   State<AIMyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<AIMyWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Get started!",
//           style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: ListView(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Padding(
//               //   padding: const EdgeInsets.only(left: 25.0),
//               //   child: Text(
//               //     "Get started!",
//               //     style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//               //   ),
//               // ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Center(
//                 child: SizedBox(
//                   width: 350,
//                   height: 300,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: PageView(
//                       children: [
//                         SlideItem(
//                           title: "BEGINER\n Push-Up",
//                           description: "Enhance strength and build endurance!",
//                           imagePath: "assets/img/pushup.jpg",
//                           onPressd: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (BuildContext context) =>
//                                         PushUpDetectorView()));
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: SizedBox(
//                   width: 350,
//                   height: 300,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: PageView(
//                       children: [
//                         SlideItem(
//                           title: "BEGINER\n Squat",
//                           description:
//                               "Enhance strength and \nbuild endurance!",
//                           imagePath: "assets/img/squat.jpg",
//                           onPressd: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (BuildContext context) =>
//                                         SquatDetectorView()));
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: SizedBox(
//                   width: 350,
//                   height: 300,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: PageView(
//                       children: [
//                         SlideItem(
//                           title: "BEGINER\n Run",
//                           description:
//                               "Enhance strength and \nbuild endurance!",
//                           imagePath: "assets/img/run.jpg",
//                           onPressd: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (BuildContext context) =>
//                                         RunningTracker()));
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: SizedBox(
//                   width: 350,
//                   height: 300,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: PageView(
//                       children: [
//                         SlideItem(
//                           title: "BEGINER\n Sit-Up",
//                           description:
//                               "Enhance strength and \nbuild endurance!",
//                           imagePath: "assets/img/gapbung.jpg",
//                           onPressd: () async {
//                             // await initializeCameras();
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(
//                             //       builder: (BuildContext context) =>
//                             //           const SitUpDetectorPage()),
//                             // );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SlideItem extends StatelessWidget {
//   final String title;
//   final String description;
//   final String imagePath;
//   final VoidCallback? onPressd;

//   const SlideItem({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.imagePath,
//     this.onPressd,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         // Giảm màu nền để giảm hiện tượng xanh
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: AssetImage(imagePath),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             // ignore: deprecated_member_use
//             Colors.black.withOpacity(0.3),
//             BlendMode.darken,
//           ),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white)),
//             const SizedBox(height: 10),
//             Text(description,
//                 style: const TextStyle(fontSize: 14, color: Colors.white)),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: onPressd,
//               style: ButtonStyle(
//                 backgroundColor: WidgetStateProperty.resolveWith<Color>(
//                   (Set<WidgetState> states) {
//                     if (states.contains(WidgetState.pressed)) {
//                       return Colors.blue.shade700; // Màu khi nút được nhấn
//                     }
//                     return const Color.fromARGB(
//                         255, 72, 231, 93); // Màu bình thường
//                   },
//                 ),
//               ),
//               child: const Text(
//                 "START",
//                 style: TextStyle(color: Colors.white), // Màu chữ
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
