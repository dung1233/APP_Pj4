import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedButtonIndex = 0;
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
    return SizedBox(
      width: getWidthPercentage(context, 1),
      height: getheightPercentage(context, 0.4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Bo góc 16px
        child: SfDateRangePicker(
          headerHeight: 0,
          controller: _datePickerController,
          backgroundColor: Colors.white,
          selectionShape: DateRangePickerSelectionShape.rectangle,
          monthCellStyle: const DateRangePickerMonthCellStyle(
            cellDecoration: _MonthCellDecoration(
              backgroundColor: Colors.white,
              showIndicator: true,
              indicatorColor: Colors.green,
            ),
            todayCellDecoration: _MonthCellDecoration(
              backgroundColor: Colors.greenAccent,
              borderColor: Colors.green,
              showIndicator: false,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthCellDecoration extends Decoration {
  const _MonthCellDecoration({
    this.borderColor,
    this.backgroundColor,
    required this.showIndicator,
    this.indicatorColor,
  });

  final Color? borderColor;
  final Color? backgroundColor;
  final bool showIndicator;
  final Color? indicatorColor;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MonthCellDecorationPainter(
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      showIndicator: showIndicator,
      indicatorColor: indicatorColor,
    );
  }
}

class _MonthCellDecorationPainter extends BoxPainter {
  _MonthCellDecorationPainter({
    this.borderColor,
    this.backgroundColor,
    required this.showIndicator,
    this.indicatorColor,
  });

  final Color? borderColor;
  final Color? backgroundColor;
  final bool showIndicator;
  final Color? indicatorColor;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect bounds = offset & configuration.size!;
    _drawDecoration(canvas, bounds);
  }

  void _drawDecoration(Canvas canvas, Rect bounds) {
    final Paint paint = Paint()..color = backgroundColor ?? Colors.transparent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(5)),
      paint,
    );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    if (borderColor != null) {
      paint.color = borderColor!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, const Radius.circular(5)),
        paint,
      );
    }

    if (showIndicator) {
      paint.color = indicatorColor!;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bounds.right - 6, bounds.top + 6), 2.5, paint);
    }
  }
}
