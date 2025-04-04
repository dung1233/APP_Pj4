import 'package:training_souls/screens/ol.dart';
import 'package:training_souls/screens/ola.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thư viện để format ngày tháng

class Wellcome extends StatefulWidget {
  const Wellcome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WellcomeState createState() => _WellcomeState();
}

final List<DateTime> weekDates = List.generate(7, (i) {
  return DateTime.now().add(Duration(days: i));
});

class _WellcomeState extends State<Wellcome> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Ol()));
        },
        child: Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome & Avatar
              const SizedBox(height: 20),
              // Date Selector
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == 0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d')
                                .format(weekDates[index]), // Hiển thị ngày
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            DateFormat('E').format(weekDates[
                                index]), // Hiển thị thứ (Mon, Tue, ...)
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
