import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 50,
      child: Row(
        children: [
          const Expanded(
              child: Divider(
                  color: Color.fromARGB(255, 196, 193, 193), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(text,
                style:
                    const TextStyle(color: Color.fromARGB(255, 196, 193, 193))),
          ),
          const Expanded(
              child: Divider(
                  color: Color.fromARGB(255, 196, 193, 193), thickness: 1)),
        ],
      ),
    );
  }
}
