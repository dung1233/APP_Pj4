import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        color: const Color.fromARGB(255, 3, 3, 3),
      ),
      child: TextButton(
        onPressed: () {
          if (kDebugMode) {
            print("Login with Google!");
          }
        },
        child: const Text(
          "@ Google",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
