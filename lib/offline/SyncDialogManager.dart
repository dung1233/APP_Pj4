import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/DatabaseHelper.dart';
import 'WorkoutSyncService.dart';

class SyncDialogManager {
  final BuildContext context;
  final DatabaseHelper _dbHelper;
  final WorkoutSyncService _syncService;
  StreamSubscription? _syncStatusSubscription;

  SyncDialogManager(this.context)
      : _dbHelper = DatabaseHelper(),
        _syncService = WorkoutSyncService();

  Future<void> show() async {
    _syncStatusSubscription =
        _syncService.syncStatusStream.listen((hasPendingSync) {
      if (!hasPendingSync) {
        // Hiển thị thông báo thành công
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 50,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Thành công!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Dữ liệu đã được đồng bộ thành công!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
