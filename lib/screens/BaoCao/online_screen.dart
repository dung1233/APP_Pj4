import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({Key? key}) : super(key: key);

  @override
  _OnlineScreenState createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {
  late DateRangePickerController _datePickerController;

  bool showAvg = false;

  double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getheightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  @override
  void initState() {
    super.initState();
    _datePickerController = DateRangePickerController();
    _datePickerController.displayDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        width: getWidthPercentage(context, 1),
        height: getheightPercentage(context, 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 8),
              child: Text(
                _datePickerController.displayDate != null
                    ? "${_datePickerController.displayDate!.month.toString().padLeft(2, '0')}-${_datePickerController.displayDate!.year}"
                    : "00-0000",
                style:
                    const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 20.0,
              ),
              child: Text(' Hoat Dong '),
            ),
            const Center(
              child: Icon(
                Icons.emoji_events,
                color: Colors.yellow,
                size: 50,
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 300, // Giới hạn độ rộng
                  child: Text(
                    'Hồ sơ huấn luyện ở đây. Ngoài ra bạn có thể ghi lại các hoạt động của riêng bạn!',
                    textAlign: TextAlign.center, // Căn giữa văn bản
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.add,
                ),
                onPressed: () {
                  if (kDebugMode) {
                    print('Da vao hoat dong');
                  }
                },
                label: const Text(
                  'Them Hoat Dong ',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
