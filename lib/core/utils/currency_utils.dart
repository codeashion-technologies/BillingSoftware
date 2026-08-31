import 'package:intl/intl.dart';

abstract final class CurrencyUtils {
  static String format(num value) =>
      NumberFormat.currency(symbol: '₹ ', decimalDigits: 2).format(value);
}
