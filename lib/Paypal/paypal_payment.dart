import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/Paypal/paypal_ids.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/item.dart';

import '../screens/User/PurchasedItemsPage.dart';

class PaypalPaymentDemo extends StatelessWidget {
  final int itemId;
  final String userToken;
  const PaypalPaymentDemo({
    super.key,
    required this.itemId,
    required this.userToken,
  });

  // Hàm lấy Item theo itemId
  Future<Item?> fetchItemById(ApiService api, int itemId) async {
    try {
      final items = await api.getItems();
      final matchedItems = items.where((item) => item.id == itemId);
      return matchedItems.isNotEmpty ? matchedItems.first : null;
    } catch (e) {
      log("❌ Lỗi khi lấy item từ API: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: 350,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final api = ApiService(Dio());

              // Lấy thông tin sản phẩm theo ID
              final item = await fetchItemById(api, itemId);
              if (item == null) {
                debugPrint("❌ Không tìm thấy sản phẩm!");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Không tìm thấy sản phẩm!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final priceString = item.price.toString();
              final itemName = item.name;

              final result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => PaypalCheckoutView(
                  sandboxMode: true,
                  clientId: PayPalData.client_id,
                  secretKey: PayPalData.secret_id,
                  transactions: [
                    {
                      "amount": {
                        "total": priceString,
                        "currency": "USD",
                        "details": {
                          "subtotal": priceString,
                          "shipping": '0',
                          "shipping_discount": 0
                        }
                      },
                      "description": "Giao dịch mua $itemName.",
                      "item_list": {
                        "items": [
                          {
                            "name": itemName,
                            "quantity": 1,
                            "price": priceString,
                            "currency": "USD"
                          },
                        ],
                      }
                    }
                  ],
                  note: "Liên hệ nếu có bất kỳ câu hỏi nào.",
                  onSuccess: (params) async {
                    try {
                      log("✅ PayPal Params: $params");

                      final parsedParams = Map<String, dynamic>.from(params);
                      final orderId = parsedParams['cart'] ??
                          (parsedParams['data']
                              as Map<String, dynamic>?)?['cart'];

                      if (orderId == null) {
                        debugPrint("❌ Không tìm thấy orderId");
                        Navigator.pop(context,
                            {'error': true, 'details': "Missing orderId"});
                        return;
                      }

                      debugPrint("🛒 Order ID: $orderId");
                      debugPrint("🔐 User Token: $userToken");

                      await api.confirmPayment({
                        'itemId': itemId,
                        'orderId': orderId,
                      }, "Bearer $userToken");

                      Navigator.pop(context, {'data': parsedParams});
                    } catch (e, stack) {
                      log("❌ onSuccess error: $e\n$stack");
                      Navigator.pop(
                          context, {'error': true, 'details': e.toString()});
                    }
                  },
                  onError: (error) {
                    Navigator.pop(context, {'error': true, 'details': error});
                  },
                  onCancel: () {
                    Navigator.pop(context, {'cancelled': true});
                  },
                ),
              ));

              if (result != null &&
                  result['error'] != true &&
                  result['cancelled'] != true) {
                debugPrint("🎉 Payment Successful: ${result['data']}");

                // ✅ Hiển thị popup sau khi thanh toán
                await showDialog(
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
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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
                                          builder: (context) =>
                                              const PurchasedItemsPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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
              } else if (result?['cancelled'] == true) {
                debugPrint("⚠️ Payment Cancelled");
              } else {
                debugPrint("❌ Payment Error: ${result?['details']}");
              }
            },
            backgroundColor: Colors.blue[800],
            icon: const Icon(Icons.payment, color: Colors.white),
            label: const Text(
              'Pay with PayPal',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}
