import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  _RankScreenState createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  late DateRangePickerController _datePickerController;
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
      height: getheightPercentage(context, 0.4),
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
