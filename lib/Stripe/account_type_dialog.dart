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
    with TickerProviderStateMixin {
  late String _currentSelection;
  late AnimationController _controller;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

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
      duration: const Duration(milliseconds: 350),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _slideController.forward();

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

    Navigator.of(context).pop();

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
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildInitialOptions() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 8),
              const Text(
                "Chọn gói dịch vụ",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Nâng cấp để mở khóa tính năng",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...widget.options.map((option) {
          final bool isPremium = option == "Premium";
          final bool isSelected = _currentSelection == option;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: isPremium && isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.orange.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: !isPremium && isSelected
                  ? Colors.grey.shade100
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? isPremium
                        ? Colors.orange.shade600
                        : Colors.grey.shade400
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? isPremium
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2)
                      : Colors.transparent,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentSelection = option;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? isPremium
                                              ? Colors.white
                                              : Colors.orange
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isPremium
                                        ? "Trải nghiệm toàn diện"
                                        : "Bắt đầu miễn phí",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? isPremium
                                              ? Colors.white.withOpacity(0.9)
                                              : Colors.grey[600]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "PHỔ BIẾN",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (isPremium && _selectedItem != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Chỉ với",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          "\$${_selectedItem!.price.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.orange,
                                          ),
                                        ),
                                        // Text(
                                        //   " USD",
                                        //   style: TextStyle(
                                        //     fontSize: 14,
                                        //     color: isSelected
                                        //         ? Colors.white70
                                        //         : Colors.grey[600],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${_selectedItem!.durationInDays} ngày",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    Container(
                      height: 1,
                      color: isPremium
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.shade300,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quyền lợi của bạn:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isPremium ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...(isPremium
                              ? [
                                  _buildBenefitItem(
                                      "Truy cập tất cả bài tập nâng cao",
                                      Icons.fitness_center_rounded,
                                      isPremium),
                                  _buildBenefitItem("Theo dõi chi tiết tiến độ",
                                      Icons.analytics_rounded, isPremium),
                                  _buildBenefitItem(
                                      "Video hướng dẫn chất lượng cao",
                                      Icons.play_circle_filled_rounded,
                                      isPremium),
                                  _buildBenefitItem("Hỗ trợ 24/7 từ chuyên gia",
                                      Icons.support_agent_rounded, isPremium),
                                  _buildBenefitItem("AI hướng dẫn check lỗi",
                                      Icons.devices_rounded, isPremium),
                                ]
                              : [
                                  _buildBenefitItem("Truy cập bài tập cơ bản",
                                      Icons.fitness_center_rounded, isPremium),
                                  _buildBenefitItem("Theo dõi tiến độ cơ bản",
                                      Icons.analytics_rounded, isPremium),
                                  _buildBenefitItem("Sử dụng trên 1 thiết bị",
                                      Icons.smartphone_rounded, isPremium),
                                ]),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
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
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
            shadowColor: Colors.orange.withOpacity(0.5),
          ),
          child: const Text(
            "Tiếp tục",
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

  Widget _buildBenefitItem(String text, IconData icon, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isPremium
                  ? Colors.white.withOpacity(0.2)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isPremium ? Colors.white : Colors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isPremium ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Chọn phương thức thanh toán",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Chọn cách thanh toán phù hợp với bạn",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPaymentMethodTile(
          'Stripe',
          'Thanh toán bằng thẻ tín dụng',
          Icons.credit_card_rounded,
          'Visa, Mastercard, Amex',
          Colors.blue,
          () => _goToPayment('Stripe'),
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodTile(
          'PayPal',
          'Thanh toán qua PayPal',
          Icons.account_balance_wallet_rounded,
          'Thanh toán an toàn và nhanh chóng',
          Colors.indigo,
          () => _goToPayment('PayPal'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    String title,
    String subtitle,
    IconData icon,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 360,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _isLoading
                          ? Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orange.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Đang tải...",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
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
          ),
        ),
      ),
    );
  }
}
