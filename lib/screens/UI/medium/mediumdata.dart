import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MediumDataWidget extends StatefulWidget {
  const MediumDataWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MediumdataState createState() => _MediumdataState();
}

class _MediumdataState extends State<MediumDataWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          _coach(context, 'assets/img/squatm.jpg', 'Squat', 'Beginer Squat'),
          SizedBox(
            height: 10,
          ),
          _coach(context, 'assets/img/train.jpg', 'Push-Up', 'Beginer Push-Up'),
          SizedBox(
            height: 10,
          ),
          _coach(context, 'assets/img/runhard.jpg', 'Runner', 'Beginer Runner'),
          SizedBox(
            height: 10,
          ),
          _coach(context, 'assets/img/situp.jpg', 'Sit-Up ', 'Strength '),
        ],
      ),
    );
  }
}

Widget _coach(
  BuildContext context,
  String imagePath,
  String title,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 5, right: 5),
    child: GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('Huan luyen');
        }
      },
      child: Stack(
        alignment: Alignment.bottomLeft, // Căn chữ vào góc trái dưới
        children: [
          // Ảnh huấn luyện
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.5), // Màu bóng mờ
                  spreadRadius: 1, // Độ lan rộng của bóng
                  blurRadius: 15, // Độ mờ
                  offset:
                      Offset(0, 4), // Độ lệch (0: chính giữa, 4: đổ xuống dưới)
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
          ),

          // Chữ viết trên ảnh
          Positioned(
            bottom: 50, // Điều chỉnh vị trí chữ
            left: 15,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.09), // Nền chữ trong suốt
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Chữ màu trắng để nổi bật
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
