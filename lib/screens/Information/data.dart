import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/Information/birthday.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/widget/elevatedButton.dart';

class Datascreen extends StatefulWidget {
  const Datascreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DataState createState() => _DataState();
}

final List<Map<String, String>> options = [
  {"title": "Male", "icon": "assets/icons/male.png"},
  {"title": "Female", "icon": "assets/icons/female.png"},
  {"title": "Non", "icon": "assets/icons/Carrot.png"},
];

class _DataState extends State<Datascreen> {
  int selectedOption = -1; // Mặc định chưa chọn gì
  @override
  void initState() {
    super.initState();
    _loadGender(); // Gọi khi màn hình khởi tạo
  }

  void _loadGender() async {
    Map<String, dynamic> userData = await LocalStorage.loadUserData();
    String savedGender = userData['gender'] ?? "";

    int index = options.indexWhere((option) => option["title"] == savedGender);
    if (index != -1) {
      setState(() {
        selectedOption = index;
      });
    }

    if (kDebugMode) {
      print("🔥 Giới tính đã lưu: $savedGender");
    } // Debug
  }

  void _saveGender() async {
    String gender = options[selectedOption]["title"]!;
    await LocalStorage.saveUserData(
        gender: gender,
        activity_level: '',
        fitness_goal: '',
        medical_conditions: '');
    if (kDebugMode) {
      print("✅ Đã lưu giới tính: $gender");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: SizedBox(
                height: 100,
                width: 120,
                child: Text(
                  "What's your gender?",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = index;
                      });
                      _saveGender(); // Lưu ngay khi chọn
                    },
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 110, 110, 110)),
                        color: selectedOption == index
                            ? Colors.white
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            options[index]["icon"]!,
                            width: 35,
                            height: 55,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            options[index]["title"]!,
                            style: TextStyle(
                                color: selectedOption == index
                                    ? Colors.black
                                    : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Buttonscreen(
              isEnabled:
                  selectedOption != -1, // Chỉ bật nút nếu đã chọn giới tính
              onPressed: () async {
                if (selectedOption == -1) {
                  return; // Nếu chưa chọn thì không làm gì cả
                }
                String gender = options[selectedOption]["title"]!;
                await LocalStorage.saveUserData(
                    gender: gender,
                    activity_level: '',
                    fitness_goal: '',
                    medical_conditions: '');
                if (kDebugMode) {
                  print("✅ Đã lưu tuổi vào LocalStorage: $gender");
                }
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => BirthDateScreen()),
                );
              },
            ),

            // Truyền trạng thái vào nút START
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
