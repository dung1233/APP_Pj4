import 'package:training_souls/screens/ol.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/screens/start/Test.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Disscover',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: ListView(
        children: [
          _sleep(context),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Bài Viết Nổi Bật',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _hotnew(context),
          SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Xây dựng Sức Mạnh',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _strong(context),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Huấn Luyện Viên Hướng Dẫn',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _coachtrain(context),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Khoi Dong & Warm up',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _warmup(context, 'assets/img/warmup.jpg', 'Lam nong co the',
                    'warmup'),
                _warmup(context, 'assets/img/warmupa.jpg', 'Keo  Gian co',
                    'warmup'),
              ],
            ),
          )
        ],
      ),
    );
  }

  SizedBox _coachtrain(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _coach(context, 'assets/img/coach.jpg', 'Huan luyen The luc',
              'Satima Training'),
          _coach(context, 'assets/img/coachrun.jpg', 'Huan luyen Toc Do ',
              'Speed Training'),
          _coach(context, 'assets/img/coachpush.jpg', 'Huan luyen Suc Manh ',
              'Strength Training'),
        ],
      ),
    );
  }

  SizedBox _strong(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _strongCart(
              context, 'assets/img/strong.jpg', 'Push-UP hard', 'Push UP'),
          _strongCart(
              context, 'assets/img/runhard.jpg', 'Runner hard', 'Long Run')
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  SizedBox _hotnew(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _blogCart(context, 'assets/img/bone.jpg', 'Xây Dựng Xương Từ Lúc Trẻ',
              'Suggestion for beginer'),
          _blogCart(
              context,
              'assets/img/train.jpg',
              '7 Lỗi Phổ  Biến Trong Luyện Tập Sức Mạnh ',
              'Suggestion for you'),
          _blogCart(
              context,
              'assets/img/dayoff.jpg',
              'Tại Sao Ngày Nghỉ Quan Trọng Tập Luyện Sức Mạnh ',
              'Suggestion for you'),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Padding _sleep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal, // Cuộn ngang
          children: [
            _buildCard(
              context,
              'assets/img/veg.jpg',
              'Nutrition',
              'Suggestion for you',
              20, // right
              50, // top
              const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold), // title style
              const TextStyle(
                  color: Colors.white, fontSize: 14), // subtitle style
              () => const Test(),
            ),
            _buildCard(
              context,
              'assets/img/sleepa.jpg',
              'Workout',
              'Stay Healthy',
              180, // right
              50, // top
              const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold), // title style
              const TextStyle(
                  color: Colors.white, fontSize: 14), // subtitle style
              () => const Ol(),
            )
          ],
        ),
      ),
    );
  }
}

Widget _warmup(
  BuildContext context,
  String imagePath,
  String title,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 10),
    child: GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('da vao warmup');
        }
      },
      child: Column(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 130,
              ),
            ),
          ),
          Container(
            width: 220, // Dùng width trực tiếp trong Container
            height: 70,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5), // Thêm SizedBox nhỏ thay cho Padding
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _coach(
  BuildContext context,
  String imagePath,
  String title,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 10),
    child: GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('huan luyen');
        }
      },
      child: Column(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 130,
              ),
            ),
          ),
          Container(
            width: 220, // Dùng width trực tiếp trong Container
            height: 70,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5), // Thêm SizedBox nhỏ thay cho Padding
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget _blogCart(
  BuildContext context,
  String imagePath,
  String title,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 10),
    child: GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('da vao muc blog xay dung xung ');
        }
      },
      child: Column(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 115,
              ),
            ),
          ),
          Container(
            width: 220, // Dùng width trực tiếp trong Container

            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5), // Thêm SizedBox nhỏ thay cho Padding
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _strongCart(
  BuildContext context,
  String imagePath,
  String title,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 10),
    child: GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('da vao stronger');
        }
      },
      child: Column(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 130,
              ),
            ),
          ),
          Container(
            width: 220,
            height: 70,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle)
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildCard(
  BuildContext context,
  String imagePath,
  String title,
  String subtitle,
  double right,
  double top,
  TextStyle titlestyle,
  TextStyle subtitlestyle,
  Widget Function() destination,
) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destination()));
      },
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150,
                width: 270,
              ),
            ),
            Positioned(
              right: right,
              top: top,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title, style: titlestyle),
                  Text(subtitle, style: subtitlestyle),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
