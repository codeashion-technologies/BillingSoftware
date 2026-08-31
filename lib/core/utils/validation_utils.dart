abstract final class ValidationUtils {
  static String? required(String? value, {String field = 'This field'}) =>
      value == null || value.trim().isEmpty ? '$field is required' : null;
}
