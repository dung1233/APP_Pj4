import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:training_souls/Paypal/paypal_ids.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:dio/dio.dart';

class PaypalPaymentDemo extends StatelessWidget {
  final int itemId;
  final String userToken;
  const PaypalPaymentDemo({
    super.key,
    required this.itemId,
    required this.userToken,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: 350,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => PaypalCheckoutView(
                  sandboxMode: true,
                  clientId: PayPalData.client_id,
                  secretKey: PayPalData.secret_id,
                  transactions: const [
                    {
                      "amount": {
                        "total": '120',
                        "currency": "USD",
                        "details": {
                          "subtotal": '120',
                          "shipping": '0',
                          "shipping_discount": 0
                        }
                      },
                      "description": "The payment transaction description.",
                      "item_list": {
                        "items": [
                          {
                            "name": "Premium Update",
                            "quantity": 1,
                            "price": '120',
                            "currency": "USD"
                          },
                        ],
                      }
                    }
                  ],
                  note: "Contact us for any questions on your order.",
                  onSuccess: (params) async {
                    try {
                      log("✅ PayPal Params: $params"); // Log toàn bộ dữ liệu trả về

                      final api = ApiService(Dio());

                      // Có thể thử cả 2 cách để debug
                      final parsedParams = Map<String, dynamic>.from(params);
                      final orderId = parsedParams['cart'] ?? (parsedParams['data'] as Map<String, dynamic>?)?['cart'];

                      if (orderId == null) {
                        debugPrint("❌ Không tìm thấy orderId từ PayPal response");
                        Navigator.pop(context, {'error': true, 'details': "Missing orderId"});
                        return;
                      }

                      debugPrint("🛒 Order ID: $orderId");
                      debugPrint("🔐 User Token: $userToken");

                      await api.confirmPayment({
                        'itemId': itemId,
                        'orderId': orderId,
                      }, "Bearer $userToken"); // 🧠 thêm Bearer nếu cần

                      Navigator.pop(context, {'data': parsedParams});
                    } catch (e, stack) {
                      log("❌ onSuccess error: $e\n$stack");
                      Navigator.pop(context, {'error': true, 'details': e.toString()});
                    }
                  }
                  ,
                  onError: (error) {
                    Navigator.pop(context, {'error': true, 'details': error});
                  },
                  onCancel: () {
                    Navigator.pop(context, {'cancelled': true});
                  },
                ),
              ));
              // Xử lý kết quả
              if (result != null && result['error'] != true && result['cancelled'] != true) {
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
                        onPressed: () {
                          Navigator.of(context).pop(); // đóng dialog
                          Navigator.of(context).pop(); // quay về trang trước (ví dụ: trang chủ)
                        },
                        child: const Text("Về trang chủ"),
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        )
    );
  }
}