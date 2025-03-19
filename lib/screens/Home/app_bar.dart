import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0x0029323d),
      toolbarHeight: 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(2);
}
