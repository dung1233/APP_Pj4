import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/Paypal/paypal_payment.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/models/item.dart';
import 'package:training_souls/Stripe/stripe_checkout_screen.dart';
import 'package:hive/hive.dart';

class AccountTypePopup extends StatefulWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onSelected;

  const AccountTypePopup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  State<AccountTypePopup> createState() => _AccountTypePopupState();
}

class _AccountTypePopupState extends State<AccountTypePopup> with SingleTickerProviderStateMixin {
  late String _currentSelection;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  List<Item> _premiumItems = [];
  Item? _selectedItem;
  bool _isLoading = true;
  bool _showPaymentMethods = false;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedOption;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    _loadPremiumItem();
  }

  Future<void> _loadPremiumItem() async {
    try {
      final api = ApiService(Dio());
      final items = await api.getItems();
      final premiums = items.where((i) => i.itemType == 'SUBSCRIPTION').toList();
      setState(() {
        _premiumItems = premiums;
        _selectedItem = premiums.isNotEmpty ? premiums.first : null;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi khi load gói: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _getToken() async {
    var box = await Hive.openBox('userBox');
    return box.get('token');
  }

  void _goToPayment(String method) async {
    final token = await _getToken();
    if (token == null || _selectedItem == null) return;

    Navigator.of(context).pop(); // đóng popup trước

    if (method == 'Stripe') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StripePaymentDemo(
            itemId: _selectedItem!.id,
            userToken: token,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaypalPaymentDemo(
            itemId: _selectedItem!.id,
            userToken: token,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInitialOptions() {
    return Column(
      children: [
        const Text("Chọn gói", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 12),
        ...widget.options.map((option) {
          return ListTile(
            title: Center(
              child: Text(option, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            subtitle: (option == "Premium" && _selectedItem != null)
                ? Center(
              child: Text(
                "${_selectedItem!.price.toStringAsFixed(0)} USD / ${_selectedItem!.durationInDays} ngày",
                style: const TextStyle(color: Colors.grey),
              ),
            )
                : null,
            trailing: _currentSelection == option ? const Icon(Icons.check, color: Colors.orange) : null,
            onTap: () {
              setState(() {
                _currentSelection = option;
              });
            },
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            widget.onSelected(_currentSelection);
            if (_currentSelection == 'Premium') {
              setState(() => _showPaymentMethods = true);
            } else {
              Navigator.pop(context); // đóng popup nếu chọn Basic
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Xác nhận", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        const Text("Chọn phương thức thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 12),
        ListTile(
          title: const Center(child: Text("Stripe")),
          onTap: () => _goToPayment('Stripe'),
        ),
        const Divider(),
        ListTile(
          title: const Center(child: Text("PayPal")),
          onTap: () => _goToPayment('PayPal'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  // constraints: const BoxConstraints(
                  //   maxHeight: 1000, // ✅ Giới hạn chiều cao tối đa
                  // ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
                      : SingleChildScrollView( // ✅ Cho phép cuộn khi nội dung vượt quá chiều cao
                    child: _showPaymentMethods
                      ? _buildPaymentMethods()
                      : _buildInitialOptions(),
                ),
              ),
              ),
            ),
          ),
          Positioned(
            bottom: 190,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.transparent,
                ),
                child: const Center(
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
