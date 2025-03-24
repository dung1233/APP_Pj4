import 'package:app/screens/ol.dart';
import 'package:flutter/material.dart';

class Wellcome extends StatefulWidget {
  const Wellcome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WellcomeState createState() => _WellcomeState();
}

List<String> getLast7Days() {
  DateTime now = DateTime.now();
  return List.generate(7, (index) {
    DateTime day = now.subtract(Duration(days: index));
    return "${day.day}"; // Định dạng dd/MM
  }).reversed.toList(); // Đảo ngược để ngày gần nhất bên phải
}

class _WellcomeState extends State<Wellcome> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 22, right: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Ol()));
        },
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Column(
            children: [
              Container(
                alignment:
                    Alignment.topLeft, // Căn toàn bộ nội dung lên trên cùng
                child: Text("WEEK GOAL",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: getLast7Days().map((date) {
                  bool isToday = date == "${DateTime.now().day}";
                  return Column(
                    children: [
                      Container(
                        width: 32, // Độ rộng nền tròn
                        height: 32, // Chiều cao nền tròn
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday ? Colors.black : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),

      /// cac ngay trong thang
      /// Total
      /// Kcal va Duration
    );
  }
}
