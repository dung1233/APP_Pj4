import 'package:flutter/material.dart';
import 'package:training_souls/Paypal/paypal_payment.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/models/item.dart';
import 'package:training_souls/models/purchase_response.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../APi/user_service.dart';
import '../../data/DatabaseHelper.dart';
import '../User/PurchasedItemsPage.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ["Tất cả", "Quần Áo", "Phụ Kiện"];
  final Dio _dio = Dio();
  late ApiService _apiService;
  final DatabaseHelper dbHelper = DatabaseHelper();
  late FocusNode _focusNode;

  List<Item> _items = [];
  bool _isLoading = false;

  String? _errorMessage;
  int _userPoints = 0;
  Map<String, dynamic>? selectedItem;
  String? _accountType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _apiService = ApiService(_dio);
    _focusNode = FocusNode();
    _loadInitialData();
    _loadUserPoints();

    // Add listener for when screen gains focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.addListener(() {
        if (_focusNode.hasFocus) {
          print("🔄 Shop screen gained focus - refreshing points...");
          _loadUserPoints();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh points when screen becomes visible
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      print("🔄 Shop screen became visible - refreshing points...");
      _loadUserPoints();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Chỉ load items, không cần Future.wait()
      final items = await _apiService.getItems();

      // Kiểm tra dữ liệu trả về
      if (items == null || items.isEmpty) {
        throw Exception('Danh sách sản phẩm trống');
      }

      setState(() {
        _items = items;
        _isLoading = false;
        // _userPoints có thể lấy từ API khác hoặc giữ nguyên giá trị mặc định
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Item> _getItemsByCategory(String category) {
    // Lọc bỏ các sản phẩm có itemType là SUBSCRIPTION
    final nonSubscriptionItems =
        _items.where((item) => item.itemType != "SUBSCRIPTION").toList();

    if (category == "Tất cả") return nonSubscriptionItems;

    return nonSubscriptionItems.where((item) {
      switch (category) {
        case "Quần Áo":
          return item.itemType == "OTHER_TYPE";
        case "Phụ Kiện":
          return item.itemType == "AVATAR";
        default:
          return false;
      }
    }).toList();
  }

  static Future<String?> getToken() async {
    var box = await Hive.openBox('userBox');
    return box.get('token');
  }

  Future<void> _handlePurchase(Item item) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để mua hàng')),
        );
        return;
      }

      final result = await _apiService.purchaseItem(item.id, "Bearer $token");

      if (result == "Purchase Success") {
        // Cập nhật điểm sau khi mua
        await _loadUserPoints();

        // Đóng popup trước khi hiển thị thông báo thành công
        Navigator.pop(context);

        // Hiển thị thông báo thành công
        _showSuccessDialog();

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Mua hàng thành công')),
        // );
      } else if (result == "Không đủ points để mua!") {
        Navigator.pop(
            context); // ✅ Đóng BottomSheet trước khi hiển thị AlertDialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Không đủ điểm'),
            content: Text('$result'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  // Cập nhật lại các thông tin người dùng (ví dụ: điểm) sau khi thanh toán thành công
                  _loadUserPoints();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Navigator.pop(
            context); // ✅ Đóng BottomSheet trước khi hiển thị AlertDialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Phản hồi không xác định:'),
            content: Text('$result'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  // Cập nhật lại các thông tin người dùng (ví dụ: điểm) sau khi thanh toán thành công
                  _loadUserPoints();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(
          context); // ✅ Đóng BottomSheet trước khi hiển thị AlertDialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi khi mua hàng:'),
          content: Text('${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                // Cập nhật lại các thông tin người dùng (ví dụ: điểm) sau khi thanh toán thành công
                _loadUserPoints();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animation container
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.orange,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: const Text(
                  'Thanh toán thành công!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Message with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Giao dịch của bạn đã được xử lý thành công.\nCảm ơn bạn đã mua hàng!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Buttons with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchasedItemsPage(),
                            ),
                          );
                          _loadUserPoints();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Xem lịch sử',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to login to make a purchase'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Điều hướng đến màn hình login
              // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  //Points
  Future<void> _loadUserPoints() async {
    if (!mounted) return; // Check if widget is still mounted

    try {
      var box = await Hive.openBox('userBox');
      final token = box.get('token');
      if (token == null) return;

      final dio = Dio();
      final client = UserService(dio);

      try {
        final response = await client.getMyInfo("Bearer $token");
        print("📌 API Response: ${response.toJson()}");

        if (response.code == 0 && mounted) {
          final user = response.result;
          print("📌 User data: ${user.toJson()}");

          setState(() {
            _userPoints = user.points ?? 0;
            _accountType = user.accountType ?? 'basic';
          });

          print("✅ Points updated: $_userPoints");
          print("👤 Account type: $_accountType");
        } else {
          print("❌ API error code: ${response.code}");
        }
      } catch (e) {
        print("❌ API call error: $e");
      }
    } catch (e) {
      print("❌ Error loading user status: $e");
    }
  }

  // paypal
  void _startPaypalCheckout(Item item) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaypalPaymentDemo(
          itemId: item.id,
          userToken: token,
        ),
      ),
    );
  }

  void _showPurchaseConfirmation() {
    if (selectedItem == null) return;

    final itemId = selectedItem!['id'];
    final itemName = selectedItem!['name'];
    final itemPoint = selectedItem!['points'];
    final itemDescription = selectedItem!['description'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/splash/slaper.png', // đường dẫn tới icon gói sản phẩm
                    width: 48,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // ignore: prefer_const_constructors
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ignore: prefer_const_constructors
                      Text('Tài Khoản : ${_accountType ?? "Chưa xác định"}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Số Points hiện có: $_userPoints',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$itemName'),
                Text('$itemPoint Points',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            // Text('+ thuế', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Divider(),
            Icon(Icons.info_outline, size: 18, color: Colors.grey),
            SizedBox(height: 4),
            Text('$itemDescription'),
            SizedBox(height: 4),
            // Text(
            //     '• Hủy bất kỳ lúc nào trong phần Gói thuê bao trên Google Play'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final Item item = selectedItem!['fullItem'];
                _handlePurchase(
                    item); // 👈 hoặc thay bằng _startPaypalCheckout(item)
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(48),
                backgroundColor: Color(0xFFFF6B00),
              ),
              child: Text(
                'Thanh toán',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold with a Focus widget
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Cửa Hàng'),
          bottom: TabBar(
            controller: _tabController,
            tabs: categories.map((tab) => Tab(text: tab)).toList(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$_userPoints'),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadInitialData,
          child: Container(
            color: Colors.white,
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final categoryItems = _getItemsByCategory(category);

                if (categoryItems.isEmpty) {
                  return const Center(child: Text('No items available'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: categoryItems.length,
                  itemBuilder: (context, index) {
                    final item = categoryItems[index];
                    return _buildItemCard(item);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selectedItem = {
              'id': item.id,
              'name': item.name,
              'points': item.points,
              'description': item.description,
              'fullItem': item, // 👈 Thêm dòng này
            };
          });
          _showPurchaseConfirmation();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _getImageForItem(item),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${item.points}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4), // khoảng cách giữa icon và text
                  const Icon(Icons.monetization_on,
                      color: Colors.amber, size: 18), // có thể chỉnh size
                ],
              ),
              const SizedBox(height: 4),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getImageForItem(Item item) {
    final name = item.name.toLowerCase();

    // Use item ID to determine which image to show
    // This ensures each item always shows the same image
    final imageIndex =
        item.id % 4; // This will give us 0,1,2,3 consistently for each item

    if (name.contains("áo")) {
      return imageIndex % 2 == 0 ? "assets/img/sh.jpg" : "assets/img/sh1.jpg";
    } else if (name.contains("quần")) {
      return "assets/img/warmup.jpg";
    } else if (name.contains("nike")) {
      // For Nike items, use the imageIndex to select from 4 different images
      switch (imageIndex) {
        case 0:
          return "assets/img/shoe.jpg";
        case 1:
          return "assets/img/shoe1.jpg";
        case 2:
          return "assets/img/shoe2.jpg";
        case 3:
          return "assets/img/runhard.jpg";
        default:
          return "assets/img/shoe.jpg";
      }
    } else {
      return "assets/img/default.jpg"; // Default image for other items
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
