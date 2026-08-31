import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.onChanged,
    this.hintText = 'Search',
    super.key,
  });
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
    ),
  );
}
