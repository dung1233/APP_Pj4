// Tạo file mới: exercise_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// ignore: depend_on_referenced_packages

class ExerciseBottomSheet extends StatefulWidget {
  final String title;
  final String animationAsset;
  final String youtubeUrl;
  final List<Map<String, String>> guide;
  final List<String> targetMuscles;

  const ExerciseBottomSheet({
    Key? key,
    required this.title,
    required this.animationAsset,
    required this.youtubeUrl,
    required this.guide,
    required this.targetMuscles,
  }) : super(key: key);

  @override
  State<ExerciseBottomSheet> createState() => _ExerciseBottomSheetState();
}

class _ExerciseBottomSheetState extends State<ExerciseBottomSheet> {
  int repetitions = 12;
  int selectedTabIndex = 0; // 0: Hoạt hình, 1: Hướng dẫn video
  late YoutubePlayerController youtubeController;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);
    youtubeController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề lớn
            Center(
              child: Text(
                widget.title,
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),

            // Phần nội dung chính
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị Lottie hoặc YouTube video
                    Center(
                      child: selectedTabIndex == 0
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Lottie.asset(
                                widget.animationAsset,
                                fit: BoxFit.contain,
                              ),
                            )
                          : YoutubePlayer(
                              controller: youtubeController,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.blueAccent,
                              progressColors: ProgressBarColors(
                                playedColor: Colors.blue,
                                handleColor: Colors.blueAccent,
                              ),
                            ),
                    ),

                    SizedBox(height: 12),

                    // Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Text("Hoạt hình"),
                          selected: selectedTabIndex == 0,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedTabIndex = 0;
                                youtubeController.pause();
                              });
                            }
                          },
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text("Hướng dẫn video"),
                          selected: selectedTabIndex == 1,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedTabIndex = 1;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Lần lặp lại
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text(
                        //   "Lần lặp lại",
                        //   style: GoogleFonts.urbanist(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.blue,
                        //   ),
                        // ),
                        // Row(
                        //   children: [
                        //     IconButton(
                        //       icon: Icon(Icons.remove_circle_outline),
                        //       onPressed: () {
                        //         if (repetitions > 1) {
                        //           setState(() => repetitions--);
                        //         }
                        //       },
                        //     ),
                        //     Text(
                        //       repetitions.toString(),
                        //       style: GoogleFonts.urbanist(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     IconButton(
                        //       icon: Icon(Icons.add_circle_outline),
                        //       onPressed: () => setState(() => repetitions++),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Hướng dẫn
                    Text(
                      "Hướng dẫn",
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 230, 101, 3),
                      ),
                    ),
                    SizedBox(height: 10),
                    ...widget.guide.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? '',
                                style: GoogleFonts.urbanist(
                                  color: Color.fromARGB(255, 230, 101, 3),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['content'] ?? '',
                                style: GoogleFonts.urbanist(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        )),

                    SizedBox(height: 12),

                    // Vùng tập trung
                    Text(
                      "Vùng tập trung",
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.targetMuscles
                          .map((muscle) => Chip(label: Text(muscle)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Nút đóng
            Center(
              child: ElevatedButton(
                onPressed: () {
                  youtubeController.pause();
                  Navigator.pop(context);
                },
                child: Text("Đóng"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hàm helper để hiển thị bottom sheet
void showExerciseBottomSheet({
  required BuildContext context,
  required String title,
  required String animationAsset,
  required String youtubeUrl,
  required List<Map<String, String>> guide,
  required List<String> targetMuscles,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ExerciseBottomSheet(
      title: title,
      animationAsset: animationAsset,
      youtubeUrl: youtubeUrl,
      guide: guide,
      targetMuscles: targetMuscles,
    ),
  );
}
