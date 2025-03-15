import 'package:flutter/material.dart';

class Ola extends StatefulWidget {
  const Ola({super.key});

  @override
  State<Ola> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Ola> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Text('data Ola'),
    );
  }
}
