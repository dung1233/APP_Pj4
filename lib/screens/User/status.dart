// Updated Dart code based on your instructions
// Changes:
// - Removed label text (e.g., "Health: ???") and replaced with only icon and ???
// - Removed "Death point"
// - Separated model and stats with Divider
// - Updated power bar with custom gradient & markers

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;
  String? chosenModel;
  bool changeModel = false;
  bool isLoading = false;
  String srcGlb1 = 'assets/3dmodel/escanor_2.glb';
  String srcGlb = 'assets/3dmodel/RunningEscanor.glb';
  late final List<String> availableModels;

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      debugPrint('Model loaded: \${controller.onModelLoaded.value}');
    });
    availableModels = [srcGlb, srcGlb1];
  }

  @override
  Widget build(BuildContext context) {
    void handleBackButton() {
      setState(() {
        isLoading = true;
        srcGlb1 = "";
      });
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Screen"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: handleBackButton,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Flutter3DViewer(
                  activeGestureInterceptor: true,
                  progressBarColor: Colors.lightBlue,
                  enableTouch: true,
                  onProgress: (double progressValue) {
                    debugPrint('Loading progress: \$progressValue');
                  },
                  onLoad: (String modelAddress) {
                    debugPrint('Model loaded: \$modelAddress');
                    controller.playAnimation();
                  },
                  onError: (String error) {
                    debugPrint('Error: \$error');
                  },
                  controller: controller,
                  src: srcGlb1,
                ),
              ),
              const Divider(thickness: 2),
              _buildInfoPanel(),
            ],
          ),
          Positioned(
            top: 16,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildFloatingButtons(),
            ),
          ),
          Positioned(
            top: 16,
            left: 20,
            child: _iconButton(Icons.accessibility_new, () async {
              String? selectedModel = await showPickerDialog(
                  'Choose Model', availableModels, srcGlb1);
              if (selectedModel != null && selectedModel != srcGlb1) {
                setState(() {
                  srcGlb1 = selectedModel;
                  chosenAnimation = null;
                  chosenTexture = null;
                });
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFCF5FD),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconOnlyRow('assets/img/name.png'),
              _iconOnlyRow('assets/img/level.png'),
              _iconOnlyRow('assets/img/title.png'),
              const Divider(),
              _buildPowerBar(),
              const Divider(),
              _iconOnlyRow('assets/img/Health.png'),
              _iconOnlyRow('assets/img/Strength.png'),
              _iconOnlyRow('assets/img/Endurance.png'),
              _iconOnlyRow('assets/img/aigilty.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconOnlyRow(String imgPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Image.asset(imgPath, width: 24, height: 24),
          const SizedBox(width: 8),
          const Text("???", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPowerBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/img/Power.png', width: 24, height: 24),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.yellow, Colors.green],
                  stops: [0.3, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(left: 0, child: _verticalMark("30")),
            Positioned(left: 100, child: _verticalMark("50")),
            Positioned(right: 0, child: _verticalMark("100")),
          ],
        ),
      ],
    );
  }

  Widget _verticalMark(String label) {
    return Column(
      children: [
        Container(width: 1, height: 20, color: Colors.black),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  List<Widget> _buildFloatingButtons() {
    return [
      _iconButton(Icons.play_arrow, () => controller.playAnimation()),
      _iconButton(Icons.pause, () => controller.pauseAnimation()),
      _iconButton(Icons.replay, () => controller.resetAnimation()),
      _iconButton(Icons.format_list_bulleted_outlined, () async {
        List<String> availableAnimations = await controller.getAvailableAnimations();
        chosenAnimation = await showPickerDialog('Animations', availableAnimations, chosenAnimation);
        controller.playAnimation(animationName: chosenAnimation);
      }),
      _iconButton(Icons.list_alt_rounded, () async {
        List<String> availableTextures = await controller.getAvailableTextures();
        chosenTexture = await showPickerDialog('Textures', availableTextures, chosenTexture);
        controller.setTexture(textureName: chosenTexture ?? '');
      }),
      _iconButton(Icons.camera_alt_outlined, () {
        controller.setCameraOrbit(20, 20, 5);
      }),
      _iconButton(Icons.cameraswitch_outlined, () {
        controller.resetCameraOrbit();
      }),
      _iconButton(Icons.restore_page_outlined, () {
        setState(() {
          changeModel = !changeModel;
          chosenAnimation = null;
          chosenTexture = null;
          srcGlb1 = changeModel
              ? 'assets/3dmodel/escanor_2.glb'
              : 'assets/3dmodel/RunningEscanor.glb';
        });
      }, size: 30),
    ];
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed, {double size = 24}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: size),
      ),
    );
  }

  Future<String?> showPickerDialog(String title, List<String> inputList,
      [String? chosenItem]) async {
    String? selectedItem = chosenItem; // Lưu model được chọn

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Cho phép kéo dài modal nếu cần
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.4, // Chiếm 40% màn hình
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded( // Ngăn lỗi RenderFlex Overflow
                    child: ListView.separated(
                      itemCount: inputList.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(
                            inputList[index],
                            overflow: TextOverflow.ellipsis, // Tránh lỗi quá dài
                            maxLines: 1,
                          ),
                          leading: Text('${index + 1}'),
                          trailing: Icon(
                            selectedItem == inputList[index]
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.blue,
                          ),
                          onTap: () {
                            setState(() {
                              selectedItem = inputList[index];
                            });
                            Future.delayed(const Duration(milliseconds: 300), () {
                              Navigator.pop(context, selectedItem);
                            });
                          },
                        );
                      },
                      separatorBuilder: (ctx, index) => const Divider(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
