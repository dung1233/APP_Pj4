import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/models/item.dart';
import 'package:training_souls/Stripe/stripe_checkout_screen.dart';

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

class _AccountTypePopupState extends State<AccountTypePopup>
    with SingleTickerProviderStateMixin {
  late String _currentSelection;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  List<Item> _premiumItems = [];
  bool _isLoading = true;

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

    _loadPremiumItems();
  }

  Future<void> _loadPremiumItems() async {
    try {
      final api = ApiService(Dio());
      final items = await api.getItems();
      setState(() {
        _premiumItems = items.where((e) => e.itemType == "SUBSCRIPTION").toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("❌ Lỗi khi tải gói premium: $e");
    }
  }

  Future<void> _handleConfirm() async {
    widget.onSelected(_currentSelection);
    if (_currentSelection == "Premium") {
      if (_premiumItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy gói premium.")),
        );
        return;
      }

      final selectedItem = _premiumItems.first;
      final box = await Hive.openBox('userBox');
      final token = box.get('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng đăng nhập.")),
        );
        return;
      }

      Navigator.pop(context); // đóng dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StripePaymentDemo(
            itemId: selectedItem.id,
            userToken: token,
          ),
        ),
      );
    } else {
      Navigator.pop(context); // đóng dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn đã chọn gói Basic")),
      );
      // TODO: gọi API để chuyển về gói Basic nếu cần
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOption(String option) {
    Widget subtitle = const SizedBox.shrink();

    if (option == "Premium") {
      if (_isLoading) {
        subtitle = const Text("Đang tải...", textAlign: TextAlign.center);
      } else if (_premiumItems.isNotEmpty) {
        final item = _premiumItems.first;
        subtitle = Text(
          "${item.price.toStringAsFixed(0)}đ / ${item.durationInDays} ngày",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
      } else {
        subtitle = const Text("Không có dữ liệu", textAlign: TextAlign.center);
      }
    }

    return ListTile(
      title: Center(
        child: Text(
          option,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: subtitle,
      trailing: _currentSelection == option
          ? const Icon(Icons.check, color: Colors.orange)
          : null,
      onTap: () {
        setState(() => _currentSelection = option);
      },
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
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Chọn gói",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 12),
                      ...widget.options.map(_buildOption),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _handleConfirm,
                          child: const Text(
                            "Xác nhận",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent, // nền trong suốt
                  border: Border.all(color: Colors.white, width: 1), // viền trắng
                ),
                child: const Icon(Icons.close_sharp, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
