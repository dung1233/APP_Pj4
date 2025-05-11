import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/Paypal/paypal_ids.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/item.dart';

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
                        Navigator.pop(context, {
                          'error': true,
                          'details': "Missing orderId"
                        });
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
                  builder: (context) => AlertDialog(
                    title: const Text("Thanh toán thành công 🎉"),
                    content: const Text("Cảm ơn bạn đã mua hàng!"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          try {
                            final DatabaseHelper _databaseHelper =
                            DatabaseHelper();
                            await _databaseHelper.updateUserInfoFromAPI();

                            Navigator.of(context).pop(); // Đóng dialog
                            Navigator.of(context).pop(); // Quay lại

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text("Thông tin tài khoản đã được cập nhật!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Lỗi cập nhật thông tin: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text("Về cửa hàng"),
                      ),
                    ],
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
