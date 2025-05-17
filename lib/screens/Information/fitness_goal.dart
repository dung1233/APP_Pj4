import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/Information/medical_conditions.dart';
import 'package:training_souls/widget/elevatedButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FitnessGoal extends StatefulWidget {
  const FitnessGoal({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FitnessGoalState createState() => _FitnessGoalState();
}

class _FitnessGoalState extends State<FitnessGoal> {
  final List<Map<String, String>> options = [
    {"title": "Giảm Mỡ", "icon": "assets/icons/loss.png"},
    {"title": "Tăng Cơ", "icon": "assets/icons/Muscle.png"},
  ];

  int selectedOption = -1;
  @override
  void initState() {
    super.initState();
    _loadfitness();
  }

  void _loadfitness() async {
    Map<String, dynamic> userData = await LocalStorage.loadUserData();
    String savefitness = userData['fitness_goal'] ?? "";
    int index =
        options.indexWhere((options) => options['title'] == savefitness);
    if (index != 1) {
      setState(() {
        selectedOption = index;
      });
    }
    if (kDebugMode) {
      print("fitness da luu $savefitness");
    }
  }

  void _savefitness() async {
    String fitnessGoal = options[selectedOption]['title']!;
    await LocalStorage.saveUserData(
        fitness_goal: fitnessGoal, activity_level: '', medical_conditions: '');
    if (kDebugMode) {
      print('✅fitness da dc luu moi: $fitnessGoal');
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
                  "What is your main fitness goal?",
                  style: GoogleFonts.urbanist(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 100),
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
                      _savefitness();
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
                            style: GoogleFonts.urbanist(
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
              isEnabled: selectedOption != -1,
              onPressed: () async {
                if (selectedOption == -1) return;
                String fitnessGoal = options[selectedOption]['title']!;
                await LocalStorage.saveUserData(
                    fitness_goal: fitnessGoal,
                    activity_level: '',
                    medical_conditions: '');
                Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            MedicalConditions()));
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
