import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:training_souls/models/rank.dart';

class RankDataSource extends DataGridSource {
  final List<Rank> _ranks;

  RankDataSource(this._ranks);

  @override
  List<DataGridRow> get rows => _ranks
      .map<DataGridRow>((rank) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'rank', value: rank.rank),
              DataGridCell<String>(columnName: 'name', value: rank.userName),
              DataGridCell<String>(
                  columnName: 'stats',
                  value:
                      '${rank.strengthScore}/${rank.enduranceScore}/${rank.healthScore}/${rank.agilityScore}'),
              DataGridCell<double>(columnName: 'total', value: rank.totalScore),
            ],
          ))
      .toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rank = row.getCells()[0].value as int;
    IconData? rankIcon;
    Color? rankColor;

    if (rank == 1) {
      rankIcon = Icons.emoji_events;
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankIcon = Icons.emoji_events_outlined;
      rankColor = Colors.grey.shade300;
    } else if (rank == 3) {
      rankIcon = Icons.emoji_events_rounded;
      rankColor = Colors.brown.shade300;
    }

    return DataGridRowAdapter(
      color: rank <= 3 ? Colors.blueGrey.shade700.withOpacity(0.7) : null,
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'rank') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (rankIcon != null)
                  Icon(rankIcon, color: rankColor, size: 16),
                SizedBox(width: rankIcon != null ? 4 : 0),
                Text(
                  cell.value.toString(),
                  style: TextStyle(
                    fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        } else if (cell.columnName == 'total') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              (cell.value as double).toStringAsFixed(1),
              style: TextStyle(
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                color: rank <= 3 ? Colors.amber : Colors.white,
              ),
            ),
          );
        } else if (cell.columnName == 'stats') {
          // Hiển thị các chỉ số với icons nhỏ
          final stats = (cell.value as String).split('/');
          if (stats.length == 4) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem(Icons.fitness_center, stats[0],
                      Colors.redAccent), // Strength
                  _buildStatItem(Icons.directions_run, stats[1],
                      Colors.greenAccent), // Endurance
                  _buildStatItem(
                      Icons.favorite, stats[2], Colors.pinkAccent), // Health
                  _buildStatItem(
                      Icons.bolt, stats[3], Colors.blueAccent), // Agility
                ],
              ),
            );
          }
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        } else {
          return Container(
            alignment: cell.columnName == 'name'
                ? Alignment.centerLeft
                : Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
