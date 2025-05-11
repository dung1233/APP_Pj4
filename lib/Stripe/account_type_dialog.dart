import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../models/item.dart';

class AccountTypePopup extends StatefulWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String, String) onConfirmed;

  const AccountTypePopup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onConfirmed,
  });

  @override
  State<AccountTypePopup> createState() => _AccountTypePopupState();
}

class _AccountTypePopupState extends State<AccountTypePopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String _currentStage = 'account'; // account → payment
  late String _currentSelection;
  Item? _premiumItem;
  bool _isLoading = false;

  final List<String> _paymentOptions = ['Stripe', 'PayPal'];
  String? _selectedPayment;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedOption;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    if (widget.options.contains('Premium')) {
      _loadPremiumItem();
    }
  }

  Future<void> _loadPremiumItem() async {
    setState(() => _isLoading = true);
    final apiService = ApiService(Dio());
    try {
      final items = await apiService.getItems();
      final premiums = items.where((i) => i.itemType == 'SUBSCRIPTION').toList();
      if (premiums.isNotEmpty) {
        setState(() => _premiumItem = premiums.first);
      }
    } catch (e) {
      print("❌ Lỗi tải gói Premium: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleConfirm() {
    if (_currentStage == 'account' && _currentSelection == 'Premium') {
      setState(() {
        _currentStage = 'payment';
        _selectedPayment = _paymentOptions.first;
      });
    } else {
      widget.onConfirmed(_currentSelection, _selectedPayment ?? '');
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOption(String option) {
    final isSelected = (_currentStage == 'account' && _currentSelection == option) ||
        (_currentStage == 'payment' && _selectedPayment == option);

    final subtitle = (_currentStage == 'account' && option == 'Premium' && _premiumItem != null)
        ? "${_premiumItem!.price.toStringAsFixed(0)}đ / ${_premiumItem!.durationInDays} ngày"
        : (_currentStage == 'account' && option == 'Basic')
        ? "Miễn phí - Giới hạn tính năng"
        : null;

    return ListTile(
      title: Center(
        child: Text(
          option,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      subtitle: subtitle != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      )
          : null,
      trailing: isSelected ? const Icon(Icons.check, color: Colors.orange) : null,
      onTap: () {
        setState(() {
          if (_currentStage == 'account') {
            _currentSelection = option;
          } else {
            _selectedPayment = option;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stageTitle = _currentStage == 'account' ? "Chọn gói" : "Chọn phương thức thanh toán";
    final options = _currentStage == 'account' ? widget.options : _paymentOptions;

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
                      Text(
                        stageTitle,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ...options.map(_buildOption).toList(),
                      const SizedBox(height: 12),
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
            bottom: 200,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.transparent,
                ),
                child: const Center(
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
