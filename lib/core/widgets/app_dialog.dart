import 'package:flutter/material.dart';

abstract final class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
  }) => showDialog<T>(
    context: context,
    builder: (_) => AlertDialog(title: Text(title), content: child),
  );
}
