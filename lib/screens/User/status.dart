// Updated Dart code based on your instructions
// Changes:
// - Updated name + level on same row without icon
// - Title shown as plain text (no icon)
// - Other stats grouped in rows: Health + Strength, Endurance + Agility

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../../data/DatabaseHelper.dart';

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
  final dbHelper = DatabaseHelper();
  Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _userInfo = {};

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      debugPrint('Model loaded: \${controller.onModelLoaded.value}');
    });
    availableModels = [srcGlb, srcGlb1];
    _printDatabaseContent(dbHelper);
    _loadUserProfile(dbHelper);
  }
  Future<void> _printDatabaseContent(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;

    // Lấy và in thông tin người dùng
    final userInfo = await db.query('user_info');
    print("❓ Dữ liệu bảng user_info:");
    userInfo.forEach((user) {
      print(user);
    });

    // Lấy và in thông tin user_profile
    final userProfiles = await db.query('user_profile');
    print("❓ Dữ liệu bảng user_profile:");
    userProfiles.forEach((profile) {
      print(profile);
    });

  }
  Future<void> _loadUserProfile(DatabaseHelper dbHelper) async {
    final db = await dbHelper.database;
    final name = await db.query('user_info');
    final profiles = await db.query('user_profile');
    if (profiles.isNotEmpty) {
      setState(() {
        _userProfile = profiles.first;
        _userInfo = name.first;
      });
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Text(_userInfo['name']?.toString() ?? "Tên người dùng", style: TextStyle(fontSize: 16)),
                  Text("Level: ${_userInfo['level']?.toString() ?? "??"}", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 6),
              Text("Thành tựu: ${_userInfo['accountType'] ?? "??"}", style: TextStyle(fontSize: 16)),
              const Divider(),
              _buildPowerBar(),
              const Divider(),
              _buildStatRow('assets/img/Health.png', 'health', 'assets/img/Strength.png', 'strength'),
              _buildStatRow('assets/img/Endurance.png', 'endurance', 'assets/img/aigilty.png', 'agility'),
            ],
          ),
        ),
      ),
    );
  }

  // Thay _buildStatRow cũ bằng phiên bản mới này
  Widget _buildStatRow(String leftIcon, String leftKey, String rightIcon, String rightKey) {
    final leftValue = _userProfile[leftKey]?.toString() ?? "???";
    final rightValue = _userProfile[rightKey]?.toString() ?? "???";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Image.asset(leftIcon, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(leftValue, style: const TextStyle(fontSize: 16)),
          ]),
          Row(children: [
            Image.asset(rightIcon, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(rightValue, style: const TextStyle(fontSize: 16)),
          ]),
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