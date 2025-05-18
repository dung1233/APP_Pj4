import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/Information/kg_screen.dart';

import 'package:training_souls/widget/elevatedButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HightScreen extends StatefulWidget {
  const HightScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HightState createState() => _HightState();
}

class _HightState extends State<HightScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadhight();
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }

  void _loadhight() async {
    Map<String, dynamic> userData = await LocalStorage.loadUserData();
    int? savedHeight = userData['height'];
    if (kDebugMode) {
      print("📌 Chieu cao đã lưu trong LocalStorage: $savedHeight");
    } // Lấy giá trị cm từ local storage

    if (savedHeight != null && savedHeight >= 140 && savedHeight <= 200) {
      setState(() {
        _controller.text = savedHeight.toString();
        isButtonEnabled = true; // Chỉ bật nút nếu hợp lệ
      });
    } else {
      setState(() {
        _controller.text = ""; // Nếu không hợp lệ thì để trống
        isButtonEnabled = false;
        if (kDebugMode) {
          print("📌 Chieu cao đã lưu trong LocalStorage: $savedHeight");
        }
      });
    }
  }

  void _validateInput() {
    int? height = int.tryParse(_controller.text.trim()); // Chuyển thành số
    setState(() {
      isButtonEnabled = height != null && height >= 140 && height <= 200;
    });
  }

  void _onNextPressed() async {
    int? height = int.tryParse(_controller.text.trim()); // Chuyển về int
    if (height != null && height >= 140 && height <= 200) {
      await LocalStorage.saveUserData(
          height: height,
          activity_level: '',
          fitness_goal: '',
          medical_conditions: '');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => KgScreen()),
      );
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
            Center(
              child: SizedBox(
                height: 100,
                width: 220,
                child: Text(
                  "Hãy nhập chiều cao của bạn (cm)",
                  style: GoogleFonts.urbanist(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller, // Gán controller
                keyboardType: TextInputType.number, // Chỉ nhập số
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'Cm'),
              ),
            ),
            const Spacer(),
            Buttonscreen(
              onPressed: isButtonEnabled ? _onNextPressed : null,
              isEnabled: isButtonEnabled,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
