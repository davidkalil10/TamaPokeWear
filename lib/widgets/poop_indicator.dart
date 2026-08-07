import 'package:flutter/material.dart';

class PoopIndicator extends StatelessWidget {
  final int count;
  const PoopIndicator({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => const Text('💩', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
