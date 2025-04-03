import 'package:flutter/material.dart';
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

  void _showPurchaseConfirmation(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name),
            const SizedBox(height: 8),
            Text('Price: 1000 points'),
            const SizedBox(height: 8),
            Text('Your points: 99999'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePurchase(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
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
        appBar: AppBar(title: const Text('Shop')),
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
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
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
                children: [
                  const Icon(Icons.monetization_on,
                      size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('1000 points'),
                ],
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
