import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/Information/hight.dart';

import 'package:flutter/material.dart';

class BirthDateScreen extends StatefulWidget {
  const BirthDateScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BirthDateScreenState createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime? _selectedDate;
  bool isButtonEnabled = false;
  String? errorMessage;

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.purple, // Màu chủ đạo
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _validateAge();
      });
    }
    print(
        "📅 Người dùng đã chọn: ${picked?.day}/${picked?.month}/${picked?.year}");
    print("📊 Tuổi tính toán: $_calculatedAge");
  }

  int get _calculatedAge {
    if (_selectedDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - _selectedDate!.year;
    if (today.month < _selectedDate!.month ||
        (today.month == _selectedDate!.month &&
            today.day < _selectedDate!.day)) {
      age--;
    }
    return age;
  }

  void _validateAge() {
    int age = _calculatedAge;
    if (age < 18 || age > 50) {
      setState(() {
        errorMessage = "Tuổi phải từ 18 đến 50";
        isButtonEnabled = false;
      });
    } else {
      setState(() {
        errorMessage = null;
        isButtonEnabled = true;
      });
    }
  }

  void initState() {
    super.initState();
    _loadage();
  }

  void _loadage() async {
    Map<String, dynamic> userData = await LocalStorage.loadUserData();
    int savedAge = userData['Age'] ?? 0;
    print("📌 Tuổi đã lưu trong LocalStorage: $savedAge");
    if (savedAge >= 18 && savedAge <= 50) {
      DateTime today = DateTime.now();
      DateTime calculatedDate =
          DateTime(today.year - savedAge, today.month, today.day);

      setState(() {
        _selectedDate = calculatedDate;
        isButtonEnabled = true;
        print(
            "✅ Ngày sinh tính toán: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: SizedBox(
                height: 80,
                width: 150,
                child: Text(
                  "Birthday your ?",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Text(
              "$_calculatedAge Age",
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} (Tuổi: $_calculatedAge)'
                          : 'Chọn ngày sinh',
                    ),
                  ),
                ),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5E35B1),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: isButtonEnabled
                  ? () async {
                      if (_selectedDate != null) {
                        await LocalStorage.saveUserData(
                            age: _calculatedAge,
                            activity_level: '',
                            fitness_goal: '',
                            medical_conditions: '');
                        print(
                            "✅ Đã lưu tuổi vào LocalStorage: $_calculatedAge");
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (context) => HightScreen()),
                        );
                      }
                    }
                  : null,
              child: Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
