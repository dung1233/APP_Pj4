import 'package:flutter/material.dart';
import 'package:training_souls/Paypal/paypal_payment.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/models/item.dart';
import 'package:training_souls/models/purchase_response.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ["All", "Premium", "Clothing", "Accessories"];
  final Dio _dio = Dio();
  late ApiService _apiService;

  List<Item> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _userPoints = 0; // Giả sử user có điểm này

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _apiService = ApiService(_dio);
    _loadInitialData();
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
    if (category == "All") return _items;

    return _items.where((item) {
      switch (category) {
        case "Premium":
          return item.name.toLowerCase().contains("premium");
        case "Clothing":
          return item.name.toLowerCase().contains("shirt") ||
              item.name.toLowerCase().contains("shoe");
        case "Accessories":
          return item.name.toLowerCase().contains("avatar") ||
              item.name.toLowerCase().contains("cart");
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
    try {
      // 1. Lấy token từ storage
      final token = await getToken();
      if (token == null || token.isEmpty) {
        // Nếu không có token, hiển thị thông báo yêu cầu đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để mua hàng')),
        );
        return;
      }

      // 2. Gọi API mua hàng
      final response = await _apiService.purchaseItem(
        item.id, // ✅ Sửa thành id
        "Bearer $token",
      );

      // 4. Cập nhật lại danh sách nếu cần
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi mua hàng: ${e.toString()}')),
      );
    }
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

  void _showPurchaseConfirmation(Item item) {
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
                    children: const [
                      // ignore: prefer_const_constructors
                      Text('Tài Khoản : Premium',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Các bài tập tại nhà',
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
                Text('Ngày bắt đầu hôm nay'),
                Text(' 120 USD/Tháng',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            Text('+ thuế', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Divider(),
            Icon(Icons.info_outline, size: 18, color: Colors.grey),
            SizedBox(height: 4),
            Text('• Bạn chưa đáp ứng điều kiện dùng thử miễn phí'),
            SizedBox(height: 4),
            Text(
                '• Hủy bất kỳ lúc nào trong phần Gói thuê bao trên Google Play'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startPaypalCheckout(item); // hoặc xử lý mua hàng
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shop')),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadInitialData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Shop'),
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
        onTap: () => _showPurchaseConfirmation(item),
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
                children: [],
              ),
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
    // Logic ánh xạ ảnh tương tự như trước
    if (item.name.toLowerCase().contains("premium")) {
      return "assets/img/prim.jpg";
    } else if (item.name.toLowerCase().contains("shoe")) {
      return "assets/img/shoe.jpg";
    } else if (item.name.toLowerCase().contains("shirt")) {
      return "assets/img/sh.jpg";
    } else {
      return "assets/img/prim.jpg";
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
