import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static String format(DateTime value) =>
      DateFormat('dd MMM yyyy').format(value);
  static String toDatabaseValue(DateTime value) => value.toIso8601String();
}
