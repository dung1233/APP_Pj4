import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../api/api_service.dart';
import '../trainhome.dart';

class PurchasedItemsPage extends StatefulWidget {
  const PurchasedItemsPage({Key? key}) : super(key: key);

  @override
  _PurchasedItemsPageState createState() => _PurchasedItemsPageState();
}

class _PurchasedItemsPageState extends State<PurchasedItemsPage> {
  List<dynamic> _purchasedItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPurchasedItems();
  }

  Future<void> _fetchPurchasedItems() async {
    try {
      // Lấy token từ Hive
      var box = await Hive.openBox('userBox');
      final token = box.get('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Vui lòng đăng nhập';
          _isLoading = false;
        });
        return;
      }

      // Tạo Dio và ApiService
      final dio = Dio();
      final apiService = ApiService(dio);

      // Gọi API lấy sản phẩm đã mua
      final response = await apiService.getPurchasedItems('Bearer $token');

      // Kiểm tra và xử lý phản hồi
      if (response.data['code'] == 0 && response.data['result'] != null) {
        setState(() {
          _purchasedItems = response.data['result'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể tải danh sách sản phẩm';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateBack() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Trainhome(initialIndex: 4),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Sản Phẩm Đã Mua',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đã xảy ra lỗi!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _fetchPurchasedItems(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Thử lại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _purchasedItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 80,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chưa có sản phẩm nào!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bạn chưa mua sản phẩm nào trong cửa hàng',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Đến cửa hàng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _purchasedItems.length,
                          itemBuilder: (context, index) {
                            final item = _purchasedItems[index];
                            final isPremium = item['name'] == 'Gói Tập Premium';

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isPremium
                                        ? [
                                            Colors.orange.shade100,
                                            Colors.orange.shade50
                                          ]
                                        : [
                                            Colors.blue.shade100,
                                            Colors.blue.shade50
                                          ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: isPremium
                                                  ? Colors.orange
                                                      .withOpacity(0.3)
                                                  : Colors.blue
                                                      .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isPremium
                                              ? Icons.star
                                              : Icons.fitness_center,
                                          color: isPremium
                                              ? Colors.orange
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'] ??
                                                  'Sản phẩm không xác định',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            _buildInfoRow(
                                              Icons.calendar_today,
                                              'Ngày mua:',
                                              _formatDate(item['purchasedAt']),
                                            ),
                                            const SizedBox(height: 4),
                                            _buildInfoRow(
                                              Icons.timer,
                                              'Ngày hết hạn:',
                                              _formatDate(
                                                  item['expirationDate']),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.black54,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
