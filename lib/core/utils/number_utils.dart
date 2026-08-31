abstract final class NumberUtils {
  static double parse(String value) => double.tryParse(value.trim()) ?? 0;
}
