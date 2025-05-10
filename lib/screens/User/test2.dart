import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Xóa chữ Debug ở góc phải
      title: 'Status',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Status'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;
  bool changeModel = false;
  String srcGlb1 = 'assets/3dmodel/escanor_2.glb';
  String srcGlb = 'assets/3dmodel/arena_of_valor_bijan_-_dragon_millennium.glb';

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      debugPrint('model is loaded : ${controller.onModelLoaded.value}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0d2039),
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(color: Color(0xfffffefe), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              controller.playAnimation();
            },
            icon: const Icon(Icons.play_arrow),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.pauseAnimation();
              //controller.stopAnimation();
            },
            icon: const Icon(Icons.pause),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.resetAnimation();
            },
            icon: const Icon(Icons.replay),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () async {
              List<String> availableAnimations =
              await controller.getAvailableAnimations();
              debugPrint(
                  'Animations : $availableAnimations --- Length : ${availableAnimations.length}');
              chosenAnimation = await showPickerDialog(
                  'Animations', availableAnimations, chosenAnimation);
              controller.playAnimation(animationName: chosenAnimation);
            },
            icon: const Icon(Icons.format_list_bulleted_outlined),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () async {
              List<String> availableTextures =
              await controller.getAvailableTextures();
              debugPrint(
                  'Textures : $availableTextures --- Length : ${availableTextures.length}');
              chosenTexture = await showPickerDialog(
                  'Textures', availableTextures, chosenTexture);
              controller.setTexture(textureName: chosenTexture ?? '');
            },
            icon: const Icon(Icons.list_alt_rounded),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.setCameraOrbit(20, 20, 5);
              //controller.setCameraTarget(0.3, 0.2, 0.4);
            },
            icon: const Icon(Icons.camera_alt_outlined),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              controller.resetCameraOrbit();
              //controller.resetCameraTarget();
            },
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
          const SizedBox(
            height: 4,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                changeModel = !changeModel;
                chosenAnimation = null;
                chosenTexture = null;
                if (changeModel) {
                  srcGlb1 = 'assets/3dmodel/escanor_2.glb';
                  srcGlb = 'assets/3dmodel/OPMWSaitamaPajamaDamagedSerious.glb';
                } else {
                  srcGlb1 = 'assets/3dmodel/OPMWSaitamaPajamaDamagedSerious.glb';
                  srcGlb = 'assets/3dmodel/escanor_2.glb';

                }
              });
            },
            icon: const Icon(
              Icons.restore_page_outlined,
              size: 30,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Flutter3DViewer(
              //If you pass 'true' the flutter_3d_controller will add gesture interceptor layer
              //to prevent gesture recognizers from malfunctioning on iOS and some Android devices.
              // the default value is true
              activeGestureInterceptor: true,
              //If you don't pass progressBarColor, the color of defaultLoadingProgressBar will be grey.
              //You can set your custom color or use [Colors.transparent] for hiding loadingProgressBar.
              progressBarColor: Colors.orange,
              //You can disable viewer touch response by setting 'enableTouch' to 'false'
              enableTouch: true,
              //This callBack will return the loading progress value between 0 and 1.0
              onProgress: (double progressValue) {
                debugPrint('model loading progress : $progressValue');
              },
              //This callBack will call after model loaded successfully and will return model address
              onLoad: (String modelAddress) {
                debugPrint('model loaded : $modelAddress');
                controller.playAnimation();
              },
              //this callBack will call when model failed to load and will return failure error
              onError: (String error) {
                debugPrint('model failed to load : $error');
              },
              //You can have full control of 3d model animations, textures and camera
              controller: controller,
              src: srcGlb,
              //src: 'assets/business_man.glb', //3D model with different animations
              //src: 'assets/sheen_chair.glb', //3D model with different textures
              //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb', // 3D model from URL
            ), // Khu vực model 3D
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.orange,
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
                _buildProgressRow("Power", 0.75), // Thanh tiến trình
                const Divider(color: Colors.white),
                _buildTripleRow("Health", "???", "Strength", "??"),
                _buildTripleRow("Endurance", "???", "Agility", "??"),
                const Divider(color: Colors.white),
                _buildSingleRow("Death point", "??"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripleRow(String title1, String value1, String title2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title1: $value1", style: const TextStyle(fontSize: 16, color: Colors.white)),
          Text("$title2: $value2", style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSingleRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text("$title: $value", style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildProgressRow(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title:", style: const TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white,
          color: Colors.green,
          minHeight: 10,
        ),
      ],
    );
  }
  Future<String?> showPickerDialog(String title, List<String> inputList,
      [String? chosenItem]) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 250,
          child: inputList.isEmpty
              ? Center(
            child: Text('$title list is empty'),
          )
              : ListView.separated(
            itemCount: inputList.length,
            padding: const EdgeInsets.only(top: 16),
            itemBuilder: (ctx, index) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context, inputList[index]);
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}'),
                      Text(inputList[index]),
                      Icon(
                        chosenItem == inputList[index]
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (ctx, index) {
              return const Divider(
                color: Colors.grey,
                thickness: 0.6,
                indent: 10,
                endIndent: 10,
              );
            },
          ),
        );
      },
    );
  }
}
