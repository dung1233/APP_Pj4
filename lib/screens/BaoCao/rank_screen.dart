import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:training_souls/api/api_service.dart';
import 'dart:async';
import 'package:training_souls/models/rank.dart';
// Import ApiService
import 'package:dio/dio.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  _RankScreenState createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  late DateRangePickerController _datePickerController;
  late Future<List<Rank>> _ranksFuture;
  late RankDataSource _rankDataSource;
  bool _isLoading = true;
  late ApiService _apiService;

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
    _rankDataSource = RankDataSource([]);

    // Khởi tạo ApiService
    final dio = Dio();
    _apiService = ApiService(dio);

    _loadRanks();
  }

  Future<void> _loadRanks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _ranksFuture = _apiService.getRanks();
      List<Rank> ranks = await _ranksFuture;

      // Sắp xếp theo thứ tự tăng dần của trường rank
      ranks.sort((a, b) => a.rank.compareTo(b.rank));

      setState(() {
        _rankDataSource.updateRanks(ranks);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("❌ Lỗi khi tải dữ liệu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getheightPercentage(context, 0.4),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SfDataGrid(
                source: _rankDataSource,
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
                    columnName: 'power',
                    label: const Center(child: Text('Power')),
                  ),
                  GridColumn(
                    columnName: 'deathpoint',
                    label: const Center(child: Text('Deathpoint')),
                  ),
                ],
              ),
      ),
    );
  }
}

class RankDataSource extends DataGridSource {
  List<DataGridRow> _rankData = [];

  RankDataSource(List<Rank> ranks) {
    updateRanks(ranks);
  }

  void updateRanks(List<Rank> ranks) {
    _rankData = ranks
        .map<DataGridRow>((rank) => DataGridRow(
              cells: [
                DataGridCell<int>(columnName: 'rank', value: rank.rank),
                DataGridCell<String>(columnName: 'name', value: rank.userName),
                DataGridCell<String>(
                    columnName: 'power',
                    value: rank.totalScore.toStringAsFixed(2)),
                DataGridCell<String>(
                    columnName: 'deathpoint', value: '${rank.deathpoints}'),
              ],
            ))
        .toList();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _rankData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rank = row.getCells()[0].value as int;
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
