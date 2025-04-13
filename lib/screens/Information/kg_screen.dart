import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/Information/activity_screen.dart';
import 'package:training_souls/widget/elevatedButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class KgScreen extends StatefulWidget {
  const KgScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KgScreenState createState() => _KgScreenState();
}

class _KgScreenState extends State<KgScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadKg();
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }

  void _loadKg() async {
    Map<String, dynamic> userData = await LocalStorage.loadUserData();
    int? savedweight = userData['weight']; // Lấy giá trị từ local storage

    if (kDebugMode) {
      print("📌 weight đã lưu trong LocalStorage: $savedweight");
    }

    if (savedweight != null && savedweight >= 35 && savedweight <= 100) {
      setState(() {
        _controller.text = savedweight.toString();
        isButtonEnabled = true; // Chỉ bật nút nếu hợp lệ
      });
    } else {
      setState(() {
        _controller.text = ""; // Nếu không hợp lệ thì để trống
        isButtonEnabled = false;
      });
    }
  }

  void _validateInput() {
    int? weight = int.tryParse(_controller.text.trim()); // Chuyển thành số
    setState(() {
      isButtonEnabled = weight != null && weight >= 35 && weight <= 100;
    });
  }

  void _onNextPressed() async {
    int? weight = int.tryParse(_controller.text.trim());
    if (weight != null && weight >= 35 && weight <= 100) {
      await LocalStorage.saveUserData(
          weight: weight,
          activity_level: '',
          fitness_goal: '',
          medical_conditions: '');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => ActivityScreen()),
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
            const Center(
              child: SizedBox(
                height: 100,
                width: 220,
                child: Text(
                  "Please enter your weight (kg)", // Sửa câu từ cho tự nhiên hơn
                  style: TextStyle(
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
                decoration: const InputDecoration(hintText: 'Kg'),
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
