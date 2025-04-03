// ignore: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedButtonIndex = 0;
  late DateRangePickerController _datePickerController;

  bool showAvg = false;

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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 25,
        automaticallyImplyLeading: false,
        title: const Text('ReportScreen'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Container(
            color: const Color.fromARGB(255, 226, 225, 225),
            child: Column(
              children: [
                _buildHeader(),
                _buildTabButtons(),
                IndexedStack(
                  index: _selectedButtonIndex,
                  children: [
                    _buildCalendar(),
                    _buildRank(),
                    _buildTime(),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SizedBox(
                    width: 400,
                    height: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 8),
                          child: Text(
                            _datePickerController.displayDate != null
                                ? "${_datePickerController.displayDate!.month.toString().padLeft(2, '0')}-${_datePickerController.displayDate!.year}"
                                : "00-0000",
                            style: const TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold),
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
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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

  Widget _buildTabButtons() {
    return Container(
      color: Colors.white,
      child: SizedBox(
        width: 360,
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCustomButton(0, "Lịch", Icons.date_range),
            _buildCustomButton(1, "Rank", Icons.emoji_events),
            _buildCustomButton(2, "Time", Icons.timelapse),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(int index, String label, IconData icon) {
    bool isSelected = _selectedButtonIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedButtonIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(bottom: BorderSide(color: Colors.green, width: 2))
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      width: 360,
      height: 300,
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

  Widget _buildRank() {
    return SizedBox(
      height: 300,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: SfDataGrid(
          source: RankDataSource(),
          columnWidthMode: ColumnWidthMode.fill,
          columns: <GridColumn>[
            GridColumn(
              columnName: 'rank',
              label: const Center(child: Text('Rank')),
            ),
            GridColumn(
              columnName: 'name',
              label: const Center(child: Text('Name')),
            ),
            GridColumn(
              columnName: 'score',
              label: const Center(child: Text('Score')),
            ),
            GridColumn(
              columnName: 'total',
              label: const Center(child: Text('total')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTime() {
    return const Center(
      child: Text(
        'Time ',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class RankDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows => _rankData;

  final List<DataGridRow> _rankData = List<DataGridRow>.generate(
    10,
    (index) => DataGridRow(
      cells: [
        DataGridCell<int>(columnName: 'rank', value: index + 1),
        DataGridCell<String>(columnName: 'name', value: 'User ${index + 1}'),
        DataGridCell<int>(columnName: 'score', value: 100 - index * 5),
        DataGridCell<int>(columnName: 'total', value: 100 - index * 5),
      ],
    ),
  );

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rank = row.getCells()[0].value as int; // Lấy thứ hạng từ cột rank
    IconData? cupIcon;

    if (rank == 1) {
      cupIcon = Icons.emoji_events; // Cúp vàng
    } else if (rank == 2) {
      cupIcon = Icons.emoji_events_outlined; // Cúp bạc
    } else if (rank == 3) {
      cupIcon = Icons.emoji_events_rounded; // Cúp đồng
    }

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'rank' && cupIcon != null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị thứ hạng
              Icon(cupIcon,
                  color: rank == 1
                      ? Colors.amber
                      : (rank == 2 ? Colors.grey : Colors.brown),
                  size: 16),

              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(cell.value.toString()),
              ),
            ],
          );
        } else {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(cell.value.toString()),
          );
        }
      }).toList(),
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
