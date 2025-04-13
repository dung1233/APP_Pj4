import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class HeaderScreen extends StatefulWidget {
  const HeaderScreen({super.key});

  @override
  _HeaderScreenState createState() => _HeaderScreenState();
}

class _HeaderScreenState extends State<HeaderScreen> {
  late DateRangePickerController _datePickerController;

  @override
  void initState() {
    super.initState();
    _datePickerController = DateRangePickerController();
    _datePickerController.displayDate = DateTime.now();
  }

  void _changeMonth(int offset) {
    setState(() {
      DateTime currentDate =
          _datePickerController.displayDate ?? DateTime.now();
      DateTime newDate =
          DateTime(currentDate.year, currentDate.month + offset, 1);
      _datePickerController.displayDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            _datePickerController.displayDate != null
                ? "${_datePickerController.displayDate!.month.toString().padLeft(2, '0')}-${_datePickerController.displayDate!.year}"
                : "00-0000",
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }
}
