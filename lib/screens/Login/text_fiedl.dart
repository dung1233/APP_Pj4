import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final IconData prefixIcon;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.obscureText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
              fontSize: 20, color: Color.fromARGB(255, 196, 193, 193)),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 300,
          child: TextField(
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              prefixIcon: Icon(prefixIcon, color: Colors.white),
              border: const OutlineInputBorder(),
              hintStyle: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
