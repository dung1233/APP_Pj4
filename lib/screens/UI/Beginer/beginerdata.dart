import 'package:app/screens/Train/beginerdata.dart';
import 'package:flutter/material.dart';

class BeginnerDataWidget extends StatelessWidget {
  const BeginnerDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: beginnerWorkouts.map((workout) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            color: Colors.white,
            child: ListTile(
              leading: Icon(
                workout["completed"]
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: workout["completed"] ? Colors.green : Colors.grey,
              ),
              title: Text("Day ${workout['day']} - ${workout['title']}"),
              subtitle: Text(workout["description"]),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              onTap: () {
                // Xử lý điều hướng đến màn hình tập luyện của ngày đó
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
