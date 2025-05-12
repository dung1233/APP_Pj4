import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/Stripe/stripe_ids.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/item.dart';

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
          builder: (context) => AlertDialog(
            title: const Text("Thanh toán thành công 🎉"),
            content: Text("Cảm ơn bạn đã mua $itemName!"),
            actions: [
              TextButton(
                onPressed: () async {
                  final db = DatabaseHelper();
                  await db.updateUserInfoFromAPI();
                  Navigator.pop(context); // đóng dialog
                  Navigator.pop(context); // đóng màn stripe
                },
                child: const Text("Về Trang chủ"),
              ),
            ],
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
