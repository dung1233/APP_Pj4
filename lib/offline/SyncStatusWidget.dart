import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/DatabaseHelper.dart';
import 'WorkoutSyncService.dart';

class SyncDialogManager {
  final BuildContext context;
  final DatabaseHelper _dbHelper;
  final WorkoutSyncService _syncService;
  StreamSubscription? _syncStatusSubscription;
  bool _isSyncing = false;
  int _pendingSyncs = 0;

  SyncDialogManager(this.context)
      : _dbHelper = DatabaseHelper(),
        _syncService = WorkoutSyncService();

  Future<void> show() async {
    _pendingSyncs = await _syncService.getPendingSyncCount();
    if (_pendingSyncs <= 0) return;

    _syncStatusSubscription =
        _syncService.syncStatusStream.listen((hasPendingSync) {
      if (hasPendingSync) {
        _checkPendingSyncs();
      }
    });

    _showDialog();
  }

  void _showDialog() {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.sync_problem, color: Colors.amber[800]),
              SizedBox(width: 8),
              Text('Đồng bộ dữ liệu'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Có $_pendingSyncs bài tập chưa được đồng bộ',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              if (_isSyncing)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
                )
              else
                ElevatedButton(
                  onPressed: _syncNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Đồng bộ ngay'),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkPendingSyncs() async {
    final count = await _syncService.getPendingSyncCount();
    if (count != _pendingSyncs) {
      _pendingSyncs = count;
      if (_pendingSyncs <= 0) {
        Navigator.of(context).pop();
      } else {
        _showDialog();
      }
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _showDialog();

    try {
      await _syncService.syncPendingData();
      await _checkPendingSyncs();
    } finally {
      _isSyncing = false;
      _showDialog();
    }
  }

  void dispose() {
    _syncStatusSubscription?.cancel();
  }
}

class SyncStatusWidget {
  static Future<void> showSyncDialog(BuildContext context) async {
    final manager = SyncDialogManager(context);
    await manager.show();
    manager.dispose();
  }
}
