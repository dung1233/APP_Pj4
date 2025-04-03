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
  bool isLoading = false; // Biến trạng thái loading
  String srcGlb1 = 'assets/3dmodel/escanor_2.glb';
  String srcGlb = 'assets/3dmodel/RunningEscanor.glb';
  late final List<String> availableModels;
  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      debugPrint('Model loaded: ${controller.onModelLoaded.value}');
    });
    availableModels = [srcGlb, srcGlb1]; // Khóa cứng danh sách ngay từ đầu
  }


  @override
  Widget build(BuildContext context) {
    // sua loi quay load model 3d
    void handleBackButton() {
      setState(() {
        isLoading = true; // Hiển thị vòng loading
        srcGlb1 = "";    // Xóa model
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
          onPressed: handleBackButton, // Gọi hàm chung
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: srcGlb1 == null
                    ? const Center(child: CircularProgressIndicator()) // Vòng load
                : Flutter3DViewer(
                  activeGestureInterceptor: true,
                  progressBarColor: Colors.lightBlue,
                  enableTouch: true,
                  onProgress: (double progressValue) {
                    debugPrint('Loading progress: $progressValue');
                  },
                  onLoad: (String modelAddress) {
                    debugPrint('Model loaded: $modelAddress');
                    controller.playAnimation();
                  },
                  onError: (String error) {
                    debugPrint('Error: $error');
                  },
                  controller: controller,
                  src: srcGlb1,
                ),
              ),
              _buildInfoPanel(),
              ElevatedButton(
                onPressed: handleBackButton, // Gọi hàm chung
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // Hiển thị vòng load
                    : const Text("Back"),
              ),

            ],
          ),
          Positioned(
            top: 16,  // Đưa lên trên cùng
            right: 20, // Giữ bên phải
            child: Column(
              children: _buildFloatingButtons(),

            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF384FA6), // FF là giá trị Alpha (độ trong suốt)
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripleRow("Name", "???", "Level", "??"),
          _buildSingleRow("Title", "???"),
          const Divider(color: Colors.white),
          _buildProgressRow("Power", "???", 0.75),
          const Divider(color: Colors.white),
          _buildTripleRow("Health", "???", "Strength", "??"),
          _buildTripleRow("Endurance", "???", "Agility", "??"),
          const Divider(color: Colors.white),
          _buildSingleRow("Death point", "??"),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingButtons() {
    return [
      _iconButton(Icons.play_arrow, () => controller.playAnimation()),
      _iconButton(Icons.pause, () => controller.pauseAnimation()),
      _iconButton(Icons.replay, () => controller.resetAnimation()),
      _iconButton(Icons.format_list_bulleted_outlined, () async {
        List<String> availableAnimations =
        await controller.getAvailableAnimations();
        chosenAnimation = await showPickerDialog(
            'Animations', availableAnimations, chosenAnimation);
        controller.playAnimation(animationName: chosenAnimation);
      }),
      _iconButton(Icons.list_alt_rounded, () async {
        List<String> availableTextures =
        await controller.getAvailableTextures();
        chosenTexture = await showPickerDialog(
            'Textures', availableTextures, chosenTexture);
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
      _iconButton(Icons.format_list_bulleted_outlined, () async {

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

  Widget _buildTripleRow(String title1, String value1, String title2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$title1: $value1", style: const TextStyle(fontSize: 16, color: Colors.white)),
        Text("$title2: $value2", style: const TextStyle(fontSize: 16, color: Colors.white)),
      ],
    );
  }

  Widget _buildSingleRow(String title, String value) {
    return Text("$title: $value", style: const TextStyle(fontSize: 16, color: Colors.white));
  }

  Widget _buildProgressRow(String title,  String value, double progress,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title: $value", style: const TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white,
          color: Color(0xFFDB4F31),
          minHeight: 10,
        ),
      ],
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
