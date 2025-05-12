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

class _AccountTypePopupState extends State<AccountTypePopup>
    with SingleTickerProviderStateMixin {
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
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    _loadPremiumItem();
  }

  Future<void> _loadPremiumItem() async {
    try {
      final api = ApiService(Dio());
      final items = await api.getItems();
      final premiums =
          items.where((i) => i.itemType == 'SUBSCRIPTION').toList();
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

    Navigator.of(context).pop(); // Đóng popup trước

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
        const Text(
          "Chọn gói",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 20),
        ...widget.options.map((option) {
          final bool isPremium = option == "Premium";
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _currentSelection == option
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _currentSelection == option
                    ? Colors.orange
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _currentSelection == option
                            ? Colors.orange
                            : Colors.black,
                      ),
                    ),
                  ),
                  subtitle: isPremium && _selectedItem != null
                      ? Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "\$${_selectedItem!.price.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    " USD",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${_selectedItem!.durationInDays} ngày",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : null,
                  trailing: _currentSelection == option
                      ? const Icon(Icons.check_circle,
                          color: Colors.orange, size: 28)
                      : null,
                  onTap: () {
                    setState(() {
                      _currentSelection = option;
                    });
                  },
                ),
                if (_currentSelection == option) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? "Quyền lợi Premium:" : "Quyền lợi Basic:",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(isPremium
                            ? [
                                _buildBenefitItem(
                                    "🎯 Truy cập tất cả bài tập nâng cao"),
                                _buildBenefitItem(
                                    "📊 Theo dõi chi tiết tiến độ"),
                                _buildBenefitItem(
                                    "🎬 Video hướng dẫn chất lượng cao"),
                                _buildBenefitItem(
                                    "💬 Hỗ trợ 24/7 từ chuyên gia"),
                                _buildBenefitItem("📱 Không giới hạn thiết bị"),
                              ]
                            : [
                                _buildBenefitItem("🎯 Truy cập bài tập cơ bản"),
                                _buildBenefitItem("📊 Theo dõi tiến độ cơ bản"),
                                _buildBenefitItem("📱 Sử dụng trên 1 thiết bị"),
                              ]),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            widget.onSelected(_currentSelection);
            if (_currentSelection == 'Premium') {
              setState(() => _showPaymentMethods = true);
            } else {
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text(
            "Xác nhận",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        const Text(
          "Chọn phương thức thanh toán",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 20),
        _buildPaymentMethodTile(
          'Stripe',
          'Thanh toán bằng thẻ tín dụng',
          Icons.credit_card,
          () => _goToPayment('Stripe'),
        ),
        const Divider(height: 1),
        _buildPaymentMethodTile(
          'PayPal',
          'Thanh toán qua PayPal',
          Icons.payment,
          () => _goToPayment('PayPal'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Đóng popup khi nhấn bên ngoài
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.3),
        body: Center(
          child: GestureDetector(
            onTap: () {
              // Ngăn sự kiện nhấn bên trong nội dung popup đóng popup
            },
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : SingleChildScrollView(
                          child: _showPaymentMethods
                              ? _buildPaymentMethods()
                              : _buildInitialOptions(),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
