import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/Stripe/stripe_ids.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:training_souls/data/DatabaseHelper.dart';

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

  Future<void> _handleStripePayment() async {
    try {
      final api = ApiService(_dio);

      // Gửi yêu cầu tạo Payment Intent từ Stripe
      final response = await _dio.post(
        "https://api.stripe.com/v1/payment_intents",
        options: Options(
          headers: {
            "Authorization": "Bearer ${StripeKeys.secretKey}", // Key Stripe của bạn
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
        data: {
          "amount": "12000", // $120.00 (cents)
          "currency": "usd",
          "payment_method_types[]": "card",
        },
      );

      // Log dữ liệu trả về từ Stripe để kiểm tra
      log("Stripe Response: ${response.data}");

      final clientSecret = response.data['client_secret']; // Client secret từ Stripe
      final orderId = response.data['id']; // Order ID (Payment Intent ID) từ Stripe

      // Log thông tin clientSecret và orderId
      log("Client Secret: $clientSecret");
      log("🛒 Order ID: $orderId");


      // Khởi tạo PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TrainingSouls Shop',
          style: ThemeMode.light,
        ),
      );

      // Hiển thị Payment Sheet để người dùng thanh toán
      try {
        await Stripe.instance.presentPaymentSheet();  // No need to capture return value here
        log("Payment Successful");

        debugPrint("Order ID: $orderId");
        debugPrint("🔐 User Token: ${widget.userToken}");
        // Sau khi thanh toán thành công, gửi thông tin đơn hàng lên backend
        try {
          await api.confirmPayment({
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
            content: const Text("Cảm ơn bạn đã mua hàng!"),
            actions: [
              TextButton(
                onPressed: () async {
                  final db = DatabaseHelper();
                  await db.updateUserInfoFromAPI();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Về cửa hàng"),
              ),
            ],
          ),
        );
      } catch (e) {
        log("❌ Payment Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Lỗi thanh toán: $e"),
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
