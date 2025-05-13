import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/Stripe/stripe_ids.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/item.dart';

import '../screens/User/PurchasedItemsPage.dart';

class StripePaymentDemo extends StatefulWidget {
  final int itemId;
  final String userToken;

  const StripePaymentDemo({
    super.key,
    required this.itemId,
    required this.userToken,
  });

  @override
  State<StripePaymentDemo> createState() => _StripePaymentDemoState();
}

class _StripePaymentDemoState extends State<StripePaymentDemo> {
  final Dio _dio = Dio();

  // Lấy Item theo ID từ API
  Future<Item?> fetchItemById(ApiService api, int itemId) async {
    try {
      final items = await api.getItems();
      final matched = items.where((item) => item.id == itemId);
      return matched.isNotEmpty ? matched.first : null;
    } catch (e) {
      log("❌ Lỗi khi lấy item từ API: $e");
      return null;
    }
  }

  Future<void> _handleStripePayment() async {
    try {
      final api = ApiService(_dio);

      // Lấy sản phẩm theo itemId
      final item = await fetchItemById(api, widget.itemId);
      if (item == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy sản phẩm!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final priceInCents = (item.price * 100).toInt(); // vì Stripe dùng cents
      final itemName = item.name;

      // Gửi yêu cầu tạo Payment Intent từ Stripe
      final response = await _dio.post(
        "https://api.stripe.com/v1/payment_intents",
        options: Options(
          headers: {
            "Authorization": "Bearer ${StripeKeys.secretKey}",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
        data: {
          "amount": priceInCents.toString(),
          "currency": "usd",
          "payment_method_types[]": "card",
        },
      );

      log("Stripe Response: ${response.data}");
      final clientSecret = response.data['client_secret'];
      final orderId = response.data['id'];

      // Khởi tạo Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TrainingSouls Shop',
          style: ThemeMode.light,
        ),
      );

      try {
        await Stripe.instance.presentPaymentSheet();
        log("✅ Payment Successful");

        debugPrint("🛒 Order ID: $orderId");
        debugPrint("🔐 User Token: ${widget.userToken}");

        // Gửi xác nhận thanh toán lên backend
        try {
          await api.StripePayment({
            "itemId": widget.itemId,
            "orderId": orderId,
          }, "Bearer ${widget.userToken}");
        } catch (e) {
          log("❌ Lỗi khi gọi confirmPayment: $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Lỗi xác nhận thanh toán (confirmPayment): $e"),
            backgroundColor: Colors.red,
          ));
        }

        // Hiển thị thông báo thành công
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
                                  builder: (context) =>
                                      const PurchasedItemsPage(),
                                ),
                              );
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
      } catch (e) {
        log("❌ PaymentSheet Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Lỗi khi hiển thị Payment Sheet: $e"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      log("❌ Stripe Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lỗi thanh toán: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 350,
        child: FloatingActionButton.extended(
          onPressed: _handleStripePayment,
          backgroundColor: Colors.orange,
          icon: const Icon(Icons.credit_card, color: Colors.white),
          label: const Text(
            'Pay with Card (Stripe)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
