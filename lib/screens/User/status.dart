// Updated Dart code based on your instructions
// Changes:
// - Updated name + level on same row without icon
// - Title shown as plain text (no icon)
// - Other stats grouped in rows: Health + Strength, Endurance + Agility

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../../APi/user_service.dart';
import '../../data/DatabaseHelper.dart';
import '../../data/local_storage.dart';

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
  double _powerLevel = 0.0;

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      debugPrint('Model loaded: \${controller.onModelLoaded.value}');
    });
    availableModels = [srcGlb, srcGlb1];
    _loadUserProfile(dbHelper);
  }

  Future<void> _loadUserProfile(DatabaseHelper dbHelper) async {
    try {
      // First ensure database tables exist
      await dbHelper.checkAndCreateTables();

      // Try to fetch data from API first
      final token = await LocalStorage.getValidToken();
      if (token != null) {
        final dio = Dio();
        dio.options.baseUrl = 'http://54.251.220.228:8080/trainingSouls';
        dio.options.headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        try {
          print("📡 Fetching data from API...");
          final response = await dio.get('/users/getMyInfo');

          if (response.data['code'] == 0 && response.data['result'] != null) {
            print("✅ API data received successfully");
            final userData = response.data['result'];
            final userProfile = userData['userProfile'];
            final totalScore =
                (userData['totalScore'] as num?)?.toDouble() ?? 0.0;

            // Update state with fresh API data
            setState(() {
              _powerLevel = totalScore;

              _userInfo = {
                'userID': userData['userID'],
                'name': userData['name'] ?? '',
                'email': userData['email'] ?? '',
                'accountType': userData['accountType'] ?? 'basic',
                'points': userData['points'] ?? 0,
                'level': userData['level'] ?? 1,
                'totalScore': totalScore
              };

              if (userProfile != null) {
                _userProfile = {
                  'userID': userData['userID'],
                  'gender': userProfile['gender'] ?? '',
                  'age': userProfile['age'] ?? 0,
                  'height': userProfile['height'] ?? 0,
                  'weight': userProfile['weight'] ?? 0,
                  'bmi': userProfile['bmi'] ?? 0.0,
                  'bodyFatPercentage': userProfile['bodyFatPercentage'] ?? 0.0,
                  'muscleMassPercentage':
                      userProfile['muscleMassPercentage'] ?? 0.0,
                  'level': userProfile['level'] ?? 'Beginner',
                  'strength': userProfile['strength'] ?? 0,
                  'deathPoints': userProfile['deathPoints'] ?? 0,
                  'agility': userProfile['agility'] ?? 0,
                  'endurance': userProfile['endurance'] ?? 0,
                  'health': userProfile['health'] ?? 0,
                };
              } else {
                _userProfile = {
                  'strength': 0,
                  'agility': 0,
                  'endurance': 0,
                  'health': 0,
                  'level': 'Beginner',
                };
              }
            });

            // After successfully getting API data, update local database as backup
            try {
              await dbHelper.insertUserInfo(_userInfo);
              if (userProfile != null) {
                await dbHelper.insertUserProfile(_userProfile);
              }
              print("✅ Local database updated with latest API data");
            } catch (dbError) {
              print("⚠️ Failed to update local database: $dbError");
            }
          } else {
            throw Exception("Invalid API response format");
          }
        } catch (apiError) {
          print("❌ API error: $apiError");
          print("⚠️ Falling back to local database...");

          // Only use local database if API completely fails
          final db = await dbHelper.database;
          try {
            final userInfos = await db.query('user_info');
            final profiles = await db.query('user_profile');

            if (userInfos.isNotEmpty) {
              setState(() {
                _userInfo = userInfos.first;
                _powerLevel =
                    (userInfos.first['totalScore'] as num?)?.toDouble() ?? 0.0;
                if (profiles.isNotEmpty) {
                  _userProfile = profiles.first;
                }
              });
              print("✅ Loaded data from local database");
            } else {
              throw Exception("No data in local database");
            }
          } catch (dbError) {
            print("❌ Local database error: $dbError");
            throw dbError;
          }
        }
      } else {
        throw Exception("No valid token found");
      }
    } catch (e) {
      print("❌ Fatal error in _loadUserProfile: $e");
      // If both API and local database fail, show error state
      setState(() {
        _powerLevel = 0.0;
        _userInfo = {
          'accountType': 'basic',
          'name': 'Unknown',
          'totalScore': 0.0
        };
        _userProfile = {
          'strength': 0,
          'agility': 0,
          'endurance': 0,
          'health': 0,
          'level': 'Beginner',
        };
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
        title: const Text("Thông Tin Người Dùng"),
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
              String? selectedModel =
                  await showPickerDialog('Chọn Mẫu', availableModels, srcGlb1);
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _userInfo['name']?.toString() ?? "Tên người dùng",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFED8F03).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "Cấp Độ ${_userInfo['level']?.toString() ?? "??"}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.military_tech_outlined,
                            color: Color(0xFF2C3E50),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Thành tựu: ${_userInfo['accountType'] ?? "??"}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildPowerSection(),
              SizedBox(height: 20),
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerSection() {
    final maxPower = 100.0;
    final powerValue = _powerLevel.clamp(0.0, maxPower);

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/img/Power.png',
                    width: 28,
                    height: 28,
                    color: _getPowerColor(powerValue),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sức Mạnh',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  "Điểm: ${powerValue.toStringAsFixed(1)}/$maxPower",
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 10,
                      right: 10,
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: powerValue / maxPower,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFFB946),
                                    Color(0xFF4ECB71),
                                  ],
                                  stops: [0.3, 0.6, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(4, (index) {
                      final positions = [0.0, 0.33, 0.66, 1.0];
                      final labels = [
                        "Mới",
                        "Trung Bình",
                        "Nâng Cao",
                        "Chuyên Gia"
                      ];
                      final markerWidth = 2.0;

                      double getAdjustedPosition() {
                        final availableWidth = constraints.maxWidth - 20;
                        final basePosition =
                            10 + (availableWidth * positions[index]);

                        if (index == 0) return basePosition;
                        if (index == 3) return basePosition - 45;
                        return basePosition - 35;
                      }

                      return Positioned(
                        left: getAdjustedPosition(),
                        top: 0,
                        child: Column(
                          crossAxisAlignment: index == 0
                              ? CrossAxisAlignment.start
                              : index == 3
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: markerWidth,
                              height: 12,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: index == 3 ? 50 : 70,
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontSize: 12,
                                ),
                                textAlign: index == 0
                                    ? TextAlign.left
                                    : index == 3
                                        ? TextAlign.right
                                        : TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow('assets/img/Health.png', 'health',
              'assets/img/Strength.png', 'strength'),
          SizedBox(height: 15),
          _buildStatRow('assets/img/Endurance.png', 'endurance',
              'assets/img/aigilty.png', 'agility'),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String leftIcon, String leftKey, String rightIcon, String rightKey) {
    return Row(
      children: [
        Expanded(child: _buildStatItem(leftIcon, leftKey)),
        SizedBox(width: 20),
        Expanded(child: _buildStatItem(rightIcon, rightKey)),
      ],
    );
  }

  Widget _buildStatItem(String icon, String key) {
    final value = _userProfile[key]?.toString() ?? "???";
    final maxValue = 100;
    final currentValue = int.tryParse(value) ?? 0;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatColor(key).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                  color: _getStatColor(key),
                ),
              ),
              SizedBox(width: 8),
              Text(
                _getStatName(key),
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: currentValue / maxValue,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatColor(key).withOpacity(0.7),
                        _getStatColor(key),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "/$maxValue",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatColor(String statType) {
    switch (statType.toLowerCase()) {
      case 'health':
        return Color(0xFFE74C3C); // Máu
      case 'strength':
        return Color(0xFFE67E22); // Sức Mạnh
      case 'endurance':
        return Color(0xFF27AE60); // Sức Bền
      case 'agility':
        return Color(0xFF3498DB); // Nhanh Nhẹn
      default:
        return Color(0xFF9B59B6); // Mặc định
    }
  }

  String _getStatName(String key) {
    switch (key.toLowerCase()) {
      case 'health':
        return 'Máu';
      case 'strength':
        return 'Sức Mạnh';
      case 'endurance':
        return 'Sức Bền';
      case 'agility':
        return 'Tốc Độ';
      default:
        return key.capitalize();
    }
  }

  Color _getPowerColor(double powerValue) {
    if (powerValue >= 95) {
      return Color(0xFF4ECB71); // Chuyên Gia - Xanh lá
    } else if (powerValue >= 66) {
      return Color(0xFFFFB946); // Nâng Cao - Cam
    } else if (powerValue >= 33) {
      return Color(0xFFFF9500); // Trung Bình - Cam nhạt
    } else {
      return Color(0xFFFF6B6B); // Mới Bắt Đầu - Đỏ
    }
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
            'Hoạt Ảnh', availableAnimations, chosenAnimation);
        controller.playAnimation(animationName: chosenAnimation);
      }),
      _iconButton(Icons.list_alt_rounded, () async {
        List<String> availableTextures =
            await controller.getAvailableTextures();
        chosenTexture =
            await showPickerDialog('Kết Cấu', availableTextures, chosenTexture);
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

  Widget _iconButton(IconData icon, VoidCallback onPressed,
      {double size = 24}) {
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
                  child: Text('Danh sách $title trống'),
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
