import 'package:flutter/material.dart';

class Buttonscreen extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed; // Nhận hàm onPressed từ bên ngoài

  const Buttonscreen({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? Color(0xFF5E35B1) : Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 150),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: isEnabled ? 5 : 0, // Chỉ có hiệu ứng nổi nếu button được bật
      ),
      onPressed: isEnabled
          ? onPressed
          : null, // Nếu isEnabled = false, button bị vô hiệu hóa
      child: Text(
        "Next",
        style: TextStyle(
          fontSize: 18,
          color: isEnabled ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
