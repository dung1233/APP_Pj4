import 'package:flutter/material.dart';
import 'package:training_souls/models/work_out.dart';

class Lolaaa extends StatefulWidget {
  const Lolaaa({Key? key}) : super(key: key);

  @override
  _LolaaaState createState() => _LolaaaState();
}

class _LolaaaState extends State<Lolaaa> {
  Workout? nextWorkout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 250,
      padding: const EdgeInsets.only(left: 25, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8),
        ],
        image: DecorationImage(
          image: AssetImage("assets/img/run.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.multiply,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            "Ngày ",
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Bài tập không tên",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 5),
          const Spacer(),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              side: const BorderSide(color: Colors.white, width: 1),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => ()));
            },
            child: const Text(
              "Bắt đầu",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  String _getWorkoutDescription(Workout workout) {
    if (workout.sets! > 0 && workout.reps! > 0) {
      return "${workout.sets} hiệp × ${workout.reps} lần";
    } else if (workout.duration! > 0) {
      return "${workout.duration} phút${workout.distance! > 0 ? ' - ${workout.distance}km' : ''}";
    }
    return "Khởi động sức mạnh"; // Mặc định
  }
}
