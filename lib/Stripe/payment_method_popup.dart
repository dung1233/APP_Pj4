import 'package:flutter/material.dart';

class PaymentMethodPopup extends StatefulWidget {
  final Function(String) onMethodSelected;

  const PaymentMethodPopup({super.key, required this.onMethodSelected});

  @override
  State<PaymentMethodPopup> createState() => _PaymentMethodPopupState();
}

class _PaymentMethodPopupState extends State<PaymentMethodPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _selected = 'Stripe';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Chọn phương thức thanh toán",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  value: 'Stripe',
                  groupValue: _selected,
                  title: const Text("Thanh toán qua Stripe"),
                  onChanged: (value) {
                    setState(() => _selected = value!);
                  },
                ),
                RadioListTile<String>(
                  value: 'PayPal',
                  groupValue: _selected,
                  title: const Text("Thanh toán qua PayPal"),
                  onChanged: (value) {
                    setState(() => _selected = value!);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onMethodSelected(_selected);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Xác nhận"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
