import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/Stripe/stripe_checkout_screen.dart';
import '../api/api_service.dart';
import '../models/item.dart';
import 'package:dio/dio.dart';

class UpgradeAccountPage extends StatefulWidget {
  final String currentAccountType;

  const UpgradeAccountPage({super.key, required this.currentAccountType});

  @override
  State<UpgradeAccountPage> createState() => _UpgradeAccountPageState();
}

class _UpgradeAccountPageState extends State<UpgradeAccountPage> {
  late ApiService _apiService;
  List<Item> _premiumItems = [];
  Item? _selectedItem;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(Dio());
    _loadPremiumItems();
  }

  Future<void> _loadPremiumItems() async {
    try {
      final items = await _apiService.getItems();
      final premiums = items.where((i) => i.itemType == 'SUBSCRIPTION').toList();

      setState(() {
        _premiumItems = premiums;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải gói: \${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // stripe
  void _startStripeCheckout(Item item) async {
    final box = await Hive.openBox('userBox');
    final token = box.get('token');
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StripePaymentDemo(
          itemId: item.id,
          userToken: token,
        ),
      ),
    );
  }
  static Future<String?> getToken() async {
    var box = await Hive.openBox('userBox');
    return box.get('token');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Nâng cấp tài khoản")),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    final isPremium = widget.currentAccountType.toLowerCase() == "premium";

    return Scaffold(
      appBar: AppBar(title: const Text("Nâng cấp tài khoản")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Chọn gói tài khoản:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _premiumItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CheckboxListTile(
                      title: const Text("Basic - Gói miễn phí"),
                      subtitle: const Text("Miễn phí - Giới hạn tính năng"),
                      value: _selectedItem == null,
                      onChanged: (val) {
                        if (val == true) {
                          setState(() => _selectedItem = null);
                        }
                      },
                    );
                  }

                  final item = _premiumItems[index - 1];
                  return CheckboxListTile(
                    title: Text(item.name),
                    subtitle: Text("${item.price.toStringAsFixed(0)}đ / ${item.durationInDays} ngày"),
                    value: _selectedItem?.id == item.id,
                    onChanged: (val) {
                      if (val == true) {
                        setState(() => _selectedItem = item);
                      } else {
                        setState(() => _selectedItem = null);
                      }
                    },
                  );
                },
              ),
            ),

            if (_selectedItem == null && isPremium)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chuyển về gói Basic")),
                    );
                    // TODO: call API hạ cấp
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Chuyển về Basic",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

            if (_selectedItem != null && !isPremium)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Tiến hành thanh toán cho gói: \${_selectedItem!.name}")),
                    );
                    _startStripeCheckout(_selectedItem!);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Thanh toán ngay",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
