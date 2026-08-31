import 'package:flutter/material.dart';

@immutable
class AppThemeExtensions extends ThemeExtension<AppThemeExtensions> {
  const AppThemeExtensions({this.tableHeaderColor = const Color(0xFFF0F3F7)});
  final Color tableHeaderColor;

  @override
  AppThemeExtensions copyWith({Color? tableHeaderColor}) => AppThemeExtensions(
    tableHeaderColor: tableHeaderColor ?? this.tableHeaderColor,
  );

  @override
  AppThemeExtensions lerp(covariant AppThemeExtensions? other, double t) =>
      AppThemeExtensions(
        tableHeaderColor:
            Color.lerp(tableHeaderColor, other?.tableHeaderColor, t) ??
            tableHeaderColor,
      );
}
