import 'package:flutter/material.dart';

class AppDataTable extends StatelessWidget {
  const AppDataTable({required this.columns, required this.rows, super.key});
  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(columns: columns, rows: rows),
  );
}
